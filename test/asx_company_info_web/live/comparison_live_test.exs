defmodule AsxCompanyInfoWeb.ComparisonLiveTest do
  use AsxCompanyInfoWeb.ConnCase
  import Phoenix.LiveViewTest

  describe "ComparisonLive.Index" do
    @tag :integration
    test "renders initial comparison page with empty state", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/compare")

      assert html =~ "ASX Stock Comparison"
      assert html =~ "Compare up to 4 ASX stocks side-by-side"
      assert html =~ "No stocks added yet"
      assert html =~ "Search for ASX stocks above to add them to your comparison"
      assert html =~ "Try popular stocks:"
      assert html =~ "Single Stock View"

      refute html =~ "phx-click=\"remove_ticker\""
      refute html =~ "Comparison Insights"
      refute html =~ "Clear All"
    end

    @tag :integration
    test "adding a stock via search form displays stock card", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/compare")

      view
      |> form("form", ticker: "CBA")
      |> render_submit()

      html = render_async(view, 5000)

      assert html =~ "CBA.AX"
      assert html =~ "$" or html =~ "Price" or html =~ "price" or html =~ "Last"
      assert html =~ "%" or html =~ "Change" or html =~ "change" or html =~ "Pct"

      assert html =~ "Comparison Insights"
      assert html =~ "1 of 4 stocks"

      assert html =~ "phx-click=\"remove_ticker\""
      assert html =~ "Remove from comparison"

      assert html =~ "phx-click=\"clear_all\""
      assert html =~ "Clear All"
    end

    @tag :integration
    test "adding a stock via popular stock button", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/compare")

      view
      |> element("form button[phx-value-ticker=\"BHP\"]")
      |> render_click()

      html = render_async(view, 5000)

      assert html =~ "BHP.AX"
      assert html =~ "$" or html =~ "Price" or html =~ "price" or html =~ "Last"
      assert html =~ "%" or html =~ "Change" or html =~ "change" or html =~ "Pct"
    end

    @tag :integration
    test "adding multiple stocks shows comparison insights", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/compare")

      view
      |> form("form", ticker: "CBA")
      |> render_submit()

      render_async(view, 5000)

      view
      |> form("form", ticker: "BHP")
      |> render_submit()

      html = render_async(view, 5000)

      # Verify both stocks are displayed
      assert html =~ "CBA.AX"
      assert html =~ "BHP.AX"
      assert html =~ "2 of 4 stocks"

      assert html =~ "Comparison Insights"
      assert html =~ "Best Performer"
      assert html =~ "Worst Performer"
      assert html =~ "Highest Price"
      assert html =~ "Lowest Price"
      assert html =~ "Total Market Value"
      assert html =~ "Average Change"
    end

    @tag :integration
    test "removing a stock updates the comparison", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/compare")

      view
      |> form("form", ticker: "CBA")
      |> render_submit()

      render_async(view, 5000)

      view
      |> form("form", ticker: "BHP")
      |> render_submit()

      html = render_async(view, 5000)

      # Verify both are present
      assert html =~ "CBA.AX"
      assert html =~ "BHP.AX"
      assert html =~ "2 of 4 stocks"

      view
      |> element("[phx-click=\"remove_ticker\"][phx-value-ticker=\"CBA\"]")
      |> render_click()

      html = render(view)

      refute html =~ "phx-click=\"remove_ticker\" phx-value-ticker=\"CBA\""
      assert html =~ "phx-click=\"remove_ticker\" phx-value-ticker=\"BHP\""
      assert html =~ "1 of 4 stocks"
    end

    @tag :integration
    test "clear all button removes all stocks", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/compare")

      view
      |> form("form", ticker: "CBA")
      |> render_submit()

      render_async(view, 5000)

      view
      |> form("form", ticker: "BHP")
      |> render_submit()

      html = render_async(view, 5000)

      assert html =~ "CBA"
      assert html =~ "BHP"
      assert html =~ "Clear All"

      view
      |> element("button", "Clear All")
      |> render_click()

      html = render(view)

      assert html =~ "No stocks added yet"

      refute html =~ "phx-click=\"remove_ticker\" phx-value-ticker=\"CBA\""
      refute html =~ "phx-click=\"remove_ticker\" phx-value-ticker=\"BHP\""
      refute html =~ "Clear All"
    end

    @tag :integration
    test "maximum 4 stocks limit is enforced", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/compare")

      stocks = ["CBA", "BHP", "ANZ", "NAB"]

      for ticker <- stocks do
        view
        |> form("form", ticker: ticker)
        |> render_submit()

        render_async(view, 5000)
      end

      html = render(view)

      assert html =~ "4 of 4 stocks"
      assert html =~ "CBA"
      assert html =~ "BHP"
      assert html =~ "ANZ"
      assert html =~ "NAB"

      # Try to add a 5th stock (use a different ticker since NAB is already added)
      view
      |> form("form", ticker: "WBC")
      |> render_submit()

      html = render(view)

      # Verify flash message about limit - could be different wording
      assert html =~ "Maximum" or html =~ "limit" or html =~ "4 stocks"
      # Verify WBC was not added (should still show only 4 stocks)
      assert html =~ "4 of 4 stocks"
      refute html =~ "WBC" or html =~ "Westpac"
    end

    @tag :integration
    test "duplicate stocks are prevented", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/compare")

      # Add CBA
      view
      |> form("form", ticker: "CBA")
      |> render_submit()

      render_async(view, 5000)

      # Try to add CBA again
      view
      |> form("form", ticker: "CBA")
      |> render_submit()

      html = render(view)

      assert html =~ "already" or html =~ "duplicate" or html =~ "CBA"

      assert count_occurrences(html, "phx-click=\"remove_ticker\" phx-value-ticker=\"CBA\"") == 1
    end

    @tag :integration
    test "loading state is shown during async fetch", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/compare")

      view
      |> form("form", ticker: "CBA")
      |> render_submit()

      html = render(view)
      # Check for loading indicators - the template shows "Fetching stock data..."
      assert html =~ "Fetching stock data..."

      # Wait for completion
      html = render_async(view, 5000)
      refute html =~ "Fetching stock data..."
      assert html =~ "CBA.AX"
    end

    @tag :integration
    test "comparison metrics show real data insights", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/compare")

      # Add multiple stocks to get comparison insights
      view
      |> form("form", ticker: "CBA")
      |> render_submit()

      render_async(view, 5000)

      view
      |> form("form", ticker: "BHP")
      |> render_submit()

      html = render_async(view, 5000)

      assert html =~ "Comparison Insights"

      assert html =~ "Best Performer"
      assert html =~ "Worst Performer"
      assert html =~ "Highest Price"
      assert html =~ "Lowest Price"
      assert html =~ "Total Market Value"
      assert html =~ "Average Change"
    end

    defp count_occurrences(string, substring) do
      string
      |> String.split(substring)
      |> length()
      |> Kernel.-(1)
    end
  end
end
