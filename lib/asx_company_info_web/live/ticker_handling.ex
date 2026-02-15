defmodule AsxCompanyInfoWeb.TickerHandling do
  @moduledoc """
  Reusable module for ticker validation and handling logic.

  This module provides common functionality for LiveViews that need to:
  1. Validate ticker input
  2. Handle ticker-related events
  3. Format error messages

  To use this module in a LiveView:

      use AsxCompanyInfoWeb.TickerHandling

  """

  @callback handle_validated_ticker(
              socket :: Phoenix.LiveView.Socket.t(),
              ticker :: String.t()
            ) :: {:noreply, Phoenix.LiveView.Socket.t()}

  defmacro __using__(_opts) do
    quote do
      use AsxCompanyInfoWeb, :live_view
      import AsxCompanyInfoWeb.TickerHandling, only: [validate_ticker: 1, format_error: 2]
      @behaviour AsxCompanyInfoWeb.TickerHandling

      @doc """
      Default implementation that handles ticker validation for common events.

      This handles events like "search", "select_popular", "add_ticker", etc.
      After validation, it calls `handle_validated_ticker/3` which must be
      implemented by the LiveView.
      """
      @impl true
      def handle_event(event, params, socket)
          when event in ["search", "select_popular", "add_ticker"] do
        case validate_ticker(params) do
          {:ok, %{"ticker" => validated_ticker}} ->
            handle_validated_ticker(socket, validated_ticker)

          {:error, error_message} ->
            {:noreply, put_flash(socket, :error, error_message)}
        end
      end
    end
  end

  @doc """
  Validates a ticker input.

  Returns `{:ok, %{"ticker" => validated_ticker}}` on success,
  or `{:error, error_message}` on failure.
  """
  def validate_ticker(ticker) do
    Zoi.map(%{
      "ticker" =>
        Zoi.string(description: "ASX ticker")
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

  @doc """
  Formats error messages for ticker-related errors.
  """
  def format_error(:not_found, ticker) do
    "Ticker '#{ticker}' not found or may be delisted"
  end

  def format_error(:bad_request, _ticker) do
    "Invalid request. Please check the ticker symbol"
  end

  def format_error(_reason, _ticker) do
    "Failed to fetch data. Please try again later"
  end
end
