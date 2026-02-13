defmodule AsxCompanyInfoWeb.CompanyLive.Index do
  use AsxCompanyInfoWeb, :live_view

  alias AsxCompanyInfo.MarketData
  import AsxCompanyInfoWeb.StockComponents

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:loading, false)
     |> assign(:error, nil)
     |> assign(:company_data, nil)
     |> assign(:quote_data, nil)
     |> assign(:current_ticker, "")
     |> assign(:form, to_form(%{"ticker" => ""}))}
  end

  @impl true
  def handle_event("search", %{"ticker" => ticker}, socket) do
    normalized_ticker =
      ticker
      |> String.trim()
      |> String.upcase()

    case validate_ticker(normalized_ticker) do
      :ok ->
        send(self(), {:fetch_data, normalized_ticker})

        {:noreply,
         socket
         |> assign(:loading, true)
         |> assign(:error, nil)
         |> assign(:current_ticker, normalized_ticker)
         |> assign(:form, to_form(%{"ticker" => normalized_ticker}))}

      {:error, error_message} ->
        {:noreply, assign(socket, :error, error_message)}
    end
  end

  @impl true
  def handle_event("select_popular", %{"ticker" => ticker}, socket) do
    send(self(), {:fetch_data, ticker})

    {:noreply,
     socket
     |> assign(:loading, true)
     |> assign(:error, nil)
     |> assign(:current_ticker, ticker)
     |> assign(:form, to_form(%{"ticker" => ticker}))}
  end

  @impl true
  def handle_info({:fetch_data, ticker}, socket) do
    # Fetch both company info and quote data in parallel
    tasks = [
      Task.async(fn -> MarketData.fetch_company_info(ticker) end),
      Task.async(fn -> MarketData.fetch_quote(ticker) end)
    ]

    results = Task.await_many(tasks, :timer.seconds(10))

    case results do
      [{:ok, company_data}, {:ok, quote_data}] ->
        {:noreply,
         socket
         |> assign(:loading, false)
         |> assign(:company_data, company_data)
         |> assign(:quote_data, quote_data)
         |> assign(:error, nil)}

      [{:error, reason}, _] ->
        {:noreply,
         socket
         |> assign(:loading, false)
         |> assign(:error, format_error(reason, ticker))}

      [_, {:error, reason}] ->
        {:noreply,
         socket
         |> assign(:loading, false)
         |> assign(:error, format_error(reason, ticker))}
    end
  end

  defp validate_ticker(ticker) do
    cond do
      String.length(ticker) < 3 ->
        {:error, "Ticker must be at least 3 characters"}

      !Regex.match?(~r/^[A-Z0-9]+$/, ticker) ->
        {:error, "Ticker must contain only letters and numbers"}

      true ->
        :ok
    end
  end

  defp format_error(:not_found, ticker) do
    "Ticker '#{ticker}' not found or may be delisted"
  end

  defp format_error(:bad_request, _ticker) do
    "Invalid request. Please check the ticker symbol"
  end

  defp format_error(_reason, _ticker) do
    "Failed to fetch company information. Please try again later"
  end
end
