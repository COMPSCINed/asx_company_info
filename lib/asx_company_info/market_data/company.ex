defmodule AsxCompanyInfo.MarketData.Company do
  @moduledoc """
  Company information struct for ASX companies.
  """
  use TypedStruct

  typedstruct do
    field :ticker, String.t()
    field :company_info, String.t()
  end
end
