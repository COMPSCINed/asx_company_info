defmodule AsxCompanyInfo.MarketData do
  @moduledoc """
  Context for fetching market data from external API using Req.
  """

  alias AsxCompanyInfo.MarketData.{Company, Quote}
  alias Helpers.ResultHelpers

  @doc """
  Fetches company information for a given ticker.
  Returns {:ok, %Company{}} or {:error, reason}
  """
  def fetch_company_info(ticker) do
    "#{base_url()}/api/market_data/company_information"
    |> get([ticker: ticker], fn body ->
      %Company{
        ticker: body["ticker"],
        company_info: body["company_info"]
      }
    end)
  end

  @doc """
  Fetches current quote data for a given ticker.
  Returns {:ok, %Quote{}} or {:error, reason}
  """
  def fetch_quote(ticker) do
    "#{base_url()}/api/market_data/quotes"
    |> get([market_key: "asx", listing_key: ticker], fn body ->
      quote_data = body["quote"] || %{}

      %Quote{
        symbol: body["symbol"],
        listing_key: body["listing_key"],
        cf_last: to_decimal(quote_data["cf_last"]),
        cf_netchng: to_decimal(quote_data["cf_netchng"]),
        pctchng: to_decimal(quote_data["pctchng"]),
        cf_volume: quote_data["cf_volume"],
        mkt_value: to_decimal(quote_data["mkt_value"]),
        "52wk_high": to_decimal(quote_data["52wk_high"])
      }
    end)
  end

  defp get(url, params, on_success, on_error \\ &Function.identity/1)
       when is_function(on_success, 1) and is_function(on_error, 1) do
    url
    |> Req.get(params: params, headers: headers(), retry: false)
    |> ResultHelpers.bind(&handle_response(&1, on_success))
    |> ResultHelpers.map_error(on_error)
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

  defp handle_response(%Req.Response{status: 200, body: body}, f), do: {:ok, f.(body)}
  defp handle_response(%Req.Response{status: 404}, _), do: {:error, :not_found}
  defp handle_response(%Req.Response{status: 400}, _), do: {:error, :bad_request}
  defp handle_response(%Req.Response{}, _), do: {:error, :api_error}

  defp to_decimal(nil), do: nil
  defp to_decimal(value) when is_float(value), do: Decimal.from_float(value)
  defp to_decimal(value), do: Decimal.new(value)
end
