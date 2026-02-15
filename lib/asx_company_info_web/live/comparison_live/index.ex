defmodule AsxCompanyInfoWeb.ComparisonLive.Index do
  use AsxCompanyInfoWeb.TickerHandling

  alias AsxCompanyInfo.MarketData
  alias Phoenix.LiveView.AsyncResult
  alias AsxCompanyInfo.MarketData.Quote
  import AsxCompanyInfoWeb.StockComponents

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:quote_data, AsyncResult.ok(nil))
     |> assign(:quotes_data, MapSet.new())
     |> assign(:max_stocks, 4)
     |> assign(:current_ticker, "")
     |> assign(:form, to_form(%{"ticker" => ""}))}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    {:noreply, calculate_comparison_metrics(socket)}
  end

  def handle_event("remove_ticker", %{"ticker" => ticker}, socket) do
    {:noreply,
     socket
     |> update(:quotes_data, fn quotes_data ->
       MapSet.reject(quotes_data, &match?(%Quote{listing_key: ^ticker}, &1))
     end)
     |> calculate_comparison_metrics()}
  end

  def handle_event("clear_all", _, socket) do
    {:noreply,
     socket
     |> assign(:quotes_data, MapSet.new())
     |> calculate_comparison_metrics()}
  end

  @impl true
  def handle_validated_ticker(socket, validated_ticker) do
    updated_socket = maybe_fetch_quote_data(socket, validated_ticker)
    {:noreply, updated_socket}
  end

  @impl true
  def handle_async(:fetch_quote_data, {:ok, {:ok, fetched_quote_data}}, socket) do
    {:noreply,
     socket
     |> assign(:quote_data, AsyncResult.ok(nil))
     |> update(:quotes_data, &MapSet.put(&1, fetched_quote_data))
     |> calculate_comparison_metrics()}
  end

  def handle_async(:fetch_quote_data, {:ok, {:error, reason}}, socket) do
    %{quote_data: quote_data, current_ticker: ticker} = socket.assigns

    {:noreply,
     socket
     |> assign(:quote_data, AsyncResult.failed(quote_data, reason))
     |> put_flash(:error, format_error(reason, ticker))}
  end

  defp maybe_fetch_quote_data(socket, validated_ticker) do
    %{quotes_data: quotes_data, max_stocks: max_stocks} = socket.assigns

    cond do
      quotes_data |> MapSet.to_list() |> Enum.find(&(&1.listing_key == validated_ticker)) ->
        put_flash(socket, :info, "Stock #{validated_ticker} is already in comparison")

      MapSet.size(quotes_data) >= max_stocks ->
        put_flash(socket, :info, "Maximum #{max_stocks} stocks allowed in comparison")

      true ->
        socket
        |> clear_flash()
        |> assign(:current_ticker, validated_ticker)
        |> fetch_quote_data(validated_ticker)
    end
  end

  defp fetch_quote_data(socket, ticker) do
    socket
    |> assign(:quote_data, AsyncResult.loading())
    |> start_async(:fetch_quote_data, fn -> MarketData.fetch_quote(ticker) end)
  end

  defp calculate_comparison_metrics(socket) do
    quotes = MapSet.to_list(socket.assigns.quotes_data)

    case quotes do
      [] ->
        socket
        |> assign(:comparison_metrics, nil)

      [_ | _] ->
        metrics = %{
          best_performer: find_best_performer(quotes),
          worst_performer: find_worst_performer(quotes),
          highest_price: find_highest_price(quotes),
          lowest_price: find_lowest_price(quotes),
          total_market_value: calculate_total_market_value(quotes),
          average_change: calculate_average_change(quotes),
          stock_count: length(quotes)
        }

        assign(socket, :comparison_metrics, metrics)
    end
  end

  defp find_best_performer(quotes), do: Enum.max_by(quotes, & &1.pctchng, Decimal)
  defp find_worst_performer(quotes), do: Enum.min_by(quotes, & &1.pctchng, Decimal)
  defp find_highest_price(quotes), do: Enum.max_by(quotes, & &1.cf_last, Decimal)
  defp find_lowest_price(quotes), do: Enum.min_by(quotes, & &1.cf_last, Decimal)

  defp calculate_total_market_value(quotes) do
    Enum.reduce(quotes, Decimal.new(0), fn quote, acc ->
      if quote.mkt_value do
        Decimal.add(acc, quote.mkt_value)
      else
        acc
      end
    end)
  end

  defp calculate_average_change(quotes) do
    pctchngs = Enum.filter(quotes, & &1.pctchng)
    count = Decimal.new(length(pctchngs))

    pctchngs
    |> Enum.reduce(Decimal.new(0), &Decimal.add(&2, &1.pctchng))
    |> Decimal.div(count)
  end
end
