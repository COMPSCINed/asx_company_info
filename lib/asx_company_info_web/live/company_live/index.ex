defmodule AsxCompanyInfoWeb.CompanyLive.Index do
  use AsxCompanyInfoWeb.TickerHandling

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
  def handle_validated_ticker(socket, validated_ticker) do
    {:noreply,
     socket
     |> clear_flash()
     |> assign_data(validated_ticker)}
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
end
