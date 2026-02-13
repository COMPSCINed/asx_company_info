defmodule AsxCompanyInfoWeb.CompanyLiveTest do
  use AsxCompanyInfoWeb.ConnCase
  import Phoenix.LiveViewTest

  test "renders initial search page", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/")
    assert html =~ "Search for Australian Stock Exchange"
    assert html =~ "Popular stocks:"
    assert html =~ "CBA"
    assert html =~ "NAB"
    assert html =~ "BHP"
  end

  test "shows validation error for short ticker", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    view
    |> form("form", ticker: "AB")
    |> render_submit()

    assert render(view) =~ "must be at least 3 characters"
  end

  test "shows validation error for invalid characters", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    view
    |> form("form", ticker: "ABC$")
    |> render_submit()

    assert render(view) =~ "must contain only letters and numbers"
  end

  @tag :integration
  test "searches for valid ticker and displays results", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    view
    |> form("form", ticker: "CBA")
    |> render_submit()

    # Wait for async data fetch
    :timer.sleep(3000)

    html = render(view)
    assert html =~ "Key Statistics"
    assert html =~ "Company Information"
    assert html =~ "Current Price"
  end

  @tag :integration
  test "clicking popular stock button triggers search", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    view
    |> element("button", "CBA")
    |> render_click()

    # Wait for async data fetch
    :timer.sleep(2000)

    html = render(view)
    assert html =~ "Key Statistics"
  end

  @tag :integration
  test "shows error for non-existent ticker", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    view
    |> form("form", ticker: "INVALID123")
    |> render_submit()

    # Wait for async data fetch
    :timer.sleep(2000)

    html = render(view)
    assert html =~ "not found" or html =~ "Failed to fetch"
  end
end
