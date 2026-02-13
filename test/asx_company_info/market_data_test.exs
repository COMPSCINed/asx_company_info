defmodule AsxCompanyInfo.MarketDataTest do
  use ExUnit.Case

  alias AsxCompanyInfo.MarketData

  @moduletag :integration

  test "fetch_company_info/1 returns company data for valid ticker" do
    assert {:ok, %MarketData.Company{ticker: "CBA", company_info: info}} =
             MarketData.fetch_company_info("CBA")

    assert is_binary(info)
  end

  test "fetch_company_info/1 returns error for invalid ticker" do
    assert {:error, _reason} = MarketData.fetch_company_info("INVALID123")
  end

  test "fetch_quote/1 returns quote data for valid ticker" do
    assert {:ok, %MarketData.Quote{symbol: symbol} = quote} = MarketData.fetch_quote("CBA")
    assert symbol =~ "CBA"
    assert %Decimal{} = quote.cf_last
  end

  test "fetch_quote/1 returns error for invalid ticker" do
    assert {:error, _reason} = MarketData.fetch_quote("INVALID123")
  end
end
