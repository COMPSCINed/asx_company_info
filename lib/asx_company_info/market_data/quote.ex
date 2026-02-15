defmodule AsxCompanyInfo.MarketData.Quote do
  @moduledoc """
  Quote data struct for ASX stock quotes.
  """
  use TypedStruct

  typedstruct do
    field :symbol, String.t()
    field :listing_key, String.t()
    field :cf_last, Decimal.t()
    field :cf_netchng, Decimal.t()
    field :pctchng, Decimal.t()
    field :cf_volume, integer()
    field :mkt_value, Decimal.t()
    field :"52wk_high", Decimal.t()
  end
end
