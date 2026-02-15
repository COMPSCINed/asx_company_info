defmodule AsxCompanyInfoWeb.CompanyLive.Index do
  use AsxCompanyInfoWeb, :live_view

  alias AsxCompanyInfo.MarketData
  alias Phoenix.LiveView.AsyncResult
  alias Helpers.ResultHelpers
  import AsxCompanyInfoWeb.StockComponents

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:company_data, AsyncResult.ok(nil))
     |> assign(:quote_data, AsyncResult.ok(nil))
     |> assign(:current_ticker, "")
     |> assign(:form, to_form(%{"ticker" => ""}))}
  end

  @impl true
  def handle_event(event, params, socket)
      when event in ["search", "select_popular"] do
    case validate_ticker(params) do
      {:ok, %{"ticker" => validated_ticker}} ->
        {:noreply,
         socket
         |> clear_flash()
         |> assign_data(validated_ticker)}

      {:error, error_message} ->
        {:noreply, put_flash(socket, :error, error_message)}
    end
  end

  defp assign_data(socket, ticker) do
    socket
    |> assign(:current_ticker, ticker)
    |> assign(:form, to_form(%{"ticker" => ticker}))
    |> fetch_company_data(ticker)
    |> fetch_quote_data(ticker)
  end

  defp fetch_company_data(socket, ticker) do
    socket
    |> assign(:company_data, AsyncResult.loading())
    |> assign_async(:company_data, fn ->
      ticker
      |> MarketData.fetch_company_info()
      |> ResultHelpers.bind(fn c -> {:ok, %{company_data: c}} end)
      |> ResultHelpers.map_error(fn reason -> format_error(reason, ticker) end)
    end)
  end

  defp fetch_quote_data(socket, ticker) do
    socket
    |> assign(:quote_data, AsyncResult.loading())
    |> assign_async(:quote_data, fn ->
      ticker
      |> MarketData.fetch_quote()
      |> ResultHelpers.bind(fn q -> {:ok, %{quote_data: q}} end)
      |> ResultHelpers.map_error(fn reason -> format_error(reason, ticker) end)
    end)
  end

  def validate_ticker(ticker) do
    Zoi.map(%{
      "ticker" =>
        Zoi.string(description: "ASC ticker")
        |> Zoi.trim()
        |> Zoi.to_upcase()
        |> Zoi.min(3)
        |> Zoi.regex(~r/^[A-Z0-9]+$/)
    })
    |> Zoi.parse(ticker)
    |> Helpers.ResultHelpers.map_error(fn
      [%Zoi.Error{code: :greater_than_or_equal_to} | _] ->
        "Ticker must be at least 3 characters"

      [%Zoi.Error{code: :invalid_format} | _] ->
        "Ticker must contain only letters and numbers"

      _ ->
        "Invalid Ticker Input"
    end)
  end

  def format_error(:not_found, ticker) do
    "Ticker '#{ticker}' not found or may be delisted"
  end

  def format_error(:bad_request, _ticker) do
    "Invalid request. Please check the ticker symbol"
  end

  def format_error(_reason, _ticker) do
    "Failed to fetch company information. Please try again later"
  end
end
