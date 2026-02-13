defmodule AsxCompanyInfo.MarketData do
  @moduledoc """
  Context for fetching market data from external API using Req.
  """

  alias AsxCompanyInfo.MarketData.{Company, Quote}

  @doc """
  Fetches company information for a given ticker.
  Returns {:ok, %Company{}} or {:error, reason}
  """
  def fetch_company_info(ticker) do
    url = "#{base_url()}/api/market_data/company_information"

    case Req.get(url, params: [ticker: ticker], headers: headers()) do
      {:ok, %Req.Response{status: 200, body: body}} ->
        {:ok,
         %Company{
           ticker: body["ticker"],
           company_info: body["company_info"]
         }}

      {:ok, %Req.Response{status: 404}} ->
        {:error, :not_found}

      {:ok, %Req.Response{status: 400}} ->
        {:error, :bad_request}

      {:ok, %Req.Response{}} ->
        {:error, :api_error}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Fetches current quote data for a given ticker.
  Returns {:ok, %Quote{}} or {:error, reason}
  """
  def fetch_quote(ticker) do
    url = "#{base_url()}/api/market_data/quotes"

    case Req.get(url, params: [market_key: "asx", listing_key: ticker], headers: headers()) do
      {:ok, %Req.Response{status: 200, body: body}} ->
        quote_data = body["quote"] || %{}

        {:ok,
         %Quote{
           symbol: body["symbol"],
           cf_last: to_decimal(quote_data["cf_last"]),
           cf_netchng: to_decimal(quote_data["cf_netchng"]),
           pctchng: to_decimal(quote_data["pctchng"]),
           cf_volume: quote_data["cf_volume"],
           mkt_value: to_decimal(quote_data["mkt_value"]),
           "52wk_high": to_decimal(quote_data["52wk_high"])
         }}

      {:ok, %Req.Response{status: 404}} ->
        {:error, :not_found}

      {:ok, %Req.Response{status: 400}} ->
        {:error, :bad_request}

      {:ok, %Req.Response{}} ->
        {:error, :api_error}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp base_url do
    Application.get_env(:asx_company_info, :api_base_url)
  end

  defp api_key do
    Application.get_env(:asx_company_info, :api_key)
  end

  defp headers do
    [
      {"Authorization", "Bearer #{api_key()}"},
      {"Content-Type", "application/json"}
    ]
  end

  defp to_decimal(nil), do: nil
  defp to_decimal(value) when is_float(value), do: Decimal.from_float(value)
  defp to_decimal(value), do: Decimal.new(value)
end
