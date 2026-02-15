defmodule AsxCompanyInfoWeb.StockComponents do
  @moduledoc """
  UI components for the CompanyInfo LiveView.
  """
  use Phoenix.Component

  slot :inner_block, required: true
  slot :action

  def asx_header(assigns) do
    ~H"""
    <header class="bg-white border-b border-[#e9ecef] py-8">
      <div class="max-w-screen-xl mx-auto px-4">
        <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
          <div>
            {render_slot(@inner_block)}
          </div>
          <div class="flex gap-3">
            {render_slot(@action)}
          </div>
        </div>
      </div>
    </header>
    """
  end

  def stat_row(assigns) do
    ~H"""
    <div class="flex justify-between items-center">
      <span class="text-[#6c757d] text-base">{@label}</span>
      <span class={[
        "text-base font-semibold",
        if(Map.get(assigns, :colored) && @value, do: value_color(@value), else: "text-[#212529]")
      ]}>
        {@value}
      </span>
    </div>
    """
  end

  def search_form(assigns) do
    assigns = assign_new(assigns, :centered, fn -> false end)
    assigns = assign_new(assigns, :submit_event, fn -> "search" end)

    ~H"""
    <.form
      for={@form}
      phx-submit={@submit_event}
      class={[
        "bg-white rounded-lg border border-[#e9ecef] p-6 shadow-sm",
        @centered && "w-full max-w-md"
      ]}
    >
      <div class="space-y-4">
        <div>
          <label class="block text-sm font-medium text-[#212529] mb-2">
            Search ASX Ticker
          </label>
          <div class="flex gap-2">
            <div class="flex-1 relative">
              <span class="absolute left-3 top-1/2 -translate-y-1/2 text-[#6c757d] font-medium">
                ASX:
              </span>
              <input
                type="text"
                name="ticker"
                value={@current_ticker}
                placeholder="e.g. CBA"
                class="w-full pl-16 pr-4 py-2 border border-[#e9ecef] rounded-md bg-white text-[#212529] placeholder:text-[#6c757d] focus:outline-none focus:ring-2 focus:ring-[#20705c] focus:border-transparent uppercase"
                phx-debounce="300"
              />
            </div>
            <button
              type="submit"
              class="px-6 py-2 bg-[#20705c] text-white rounded-md hover:bg-[#1a5c4d] focus:outline-none focus:ring-2 focus:ring-[#20705c] focus:ring-offset-2 transition-colors cursor-pointer"
            >
              Search
            </button>
          </div>
        </div>

        <div>
          <p class="text-sm text-[#6c757d] mb-2">Popular stocks:</p>
          <div class="flex gap-2">
            <%= for ticker <- ["CBA", "NAB", "BHP", "ANZ"] do %>
              <button
                type="button"
                phx-click="select_popular"
                phx-value-ticker={ticker}
                class="px-4 py-1.5 border border-[#e9ecef] rounded-md text-sm font-medium text-[#212529] hover:bg-[#f8f9fa] transition-colors cursor-pointer"
              >
                {ticker}
              </button>
            <% end %>
          </div>
        </div>
      </div>
    </.form>
    """
  end

  def key_statistics(assigns) do
    ~H"""
    <div class="bg-white rounded-lg border border-[#e9ecef] p-6 shadow-sm">
      <h2 class="text-xl font-bold text-[#212529] mb-4">Key Statistics</h2>

      <div class="space-y-3">
        <.stat_row label="Current Price" value={format_currency(@quote.cf_last)} />

        <.stat_row
          label="Change"
          value={format_change(@quote.cf_netchng, @quote.pctchng)}
          colored={true}
        />

        <.stat_row label="Volume" value={format_number(@quote.cf_volume)} />

        <.stat_row label="Market Value" value={format_market_value(@quote.mkt_value)} />

        <.stat_row label="52W High" value={format_currency(Map.get(@quote, :"52wk_high"))} />
      </div>
    </div>
    """
  end

  def company_info(assigns) do
    ~H"""
    <div class="bg-white rounded-lg border border-[#e9ecef] p-6 shadow-sm">
      <h2 class="text-xl font-bold text-[#212529] mb-4">Company Information</h2>
      <p class="text-[#212529] leading-relaxed">
        {@company.company_info}
      </p>
    </div>
    """
  end

  def loading_spinner(assigns) do
    ~H"""
    <div class="fixed inset-0 bg-black/20 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-6 shadow-lg">
        <div class="flex items-center gap-3">
          <div class="animate-spin size-6 border-2 border-[#20705c] border-t-transparent rounded-full">
          </div>
          <span class="text-[#212529]">Loading company information...</span>
        </div>
      </div>
    </div>
    """
  end

  def error_message(assigns) do
    ~H"""
    <div class="fixed bottom-4 right-4 bg-[#dc3545] text-white px-6 py-4 rounded-lg shadow-lg max-w-md z-50">
      {@message}
    </div>
    """
  end

  def comparison_summary(assigns) do
    ~H"""
    <div class="bg-white rounded-lg border border-[#e9ecef] p-6 shadow-sm">
      <h2 class="text-xl font-bold text-[#212529] mb-4">Comparison Insights</h2>

      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        <!-- Best Performer -->
        <%= if @best_performer do %>
          <div class="bg-[#f8f9fa] rounded-lg p-4">
            <div class="flex items-center justify-between mb-2">
              <span class="text-[#6c757d] text-sm font-medium">Best Performer</span>
              <span class="text-[#198754] font-bold">{@best_performer.symbol}</span>
            </div>
            <div class="text-2xl font-bold text-[#198754]">
              {format_change(@best_performer.cf_netchng, @best_performer.pctchng)}
            </div>
          </div>
        <% end %>
        
    <!-- Worst Performer -->
        <%= if @worst_performer do %>
          <div class="bg-[#f8f9fa] rounded-lg p-4">
            <div class="flex items-center justify-between mb-2">
              <span class="text-[#6c757d] text-sm font-medium">Worst Performer</span>
              <span class="text-[#dc3545] font-bold">{@worst_performer.symbol}</span>
            </div>
            <div class="text-2xl font-bold text-[#dc3545]">
              {format_change(@worst_performer.cf_netchng, @worst_performer.pctchng)}
            </div>
          </div>
        <% end %>
        
    <!-- Highest Price -->
        <%= if @highest_price do %>
          <div class="bg-[#f8f9fa] rounded-lg p-4">
            <div class="flex items-center justify-between mb-2">
              <span class="text-[#6c757d] text-sm font-medium">Highest Price</span>
              <span class="text-[#212529] font-bold">{@highest_price.symbol}</span>
            </div>
            <div class="text-2xl font-bold text-[#212529]">
              {format_currency(@highest_price.cf_last)}
            </div>
          </div>
        <% end %>
        
    <!-- Lowest Price -->
        <%= if @lowest_price do %>
          <div class="bg-[#f8f9fa] rounded-lg p-4">
            <div class="flex items-center justify-between mb-2">
              <span class="text-[#6c757d] text-sm font-medium">Lowest Price</span>
              <span class="text-[#212529] font-bold">{@lowest_price.symbol}</span>
            </div>
            <div class="text-2xl font-bold text-[#212529]">
              {format_currency(@lowest_price.cf_last)}
            </div>
          </div>
        <% end %>
        
    <!-- Total Market Value -->
        <%= if @total_market_value do %>
          <div class="bg-[#f8f9fa] rounded-lg p-4">
            <div class="flex items-center justify-between mb-2">
              <span class="text-[#6c757d] text-sm font-medium">Total Market Value</span>
              <span class="text-[#212529] font-bold">{@stock_count} stocks</span>
            </div>
            <div class="text-2xl font-bold text-[#212529]">
              {format_market_value(@total_market_value)}
            </div>
          </div>
        <% end %>
        
    <!-- Average Change -->
        <%= if @average_change do %>
          <div class="bg-[#f8f9fa] rounded-lg p-4">
            <div class="flex items-center justify-between mb-2">
              <span class="text-[#6c757d] text-sm font-medium">Average Change</span>
              <span class={[
                "font-bold",
                if(Decimal.positive?(@average_change), do: "text-[#198754]", else: "text-[#dc3545]")
              ]}>
                <%= if Decimal.positive?(@average_change) do %>
                  ↗
                <% else %>
                  ↘
                <% end %>
              </span>
            </div>
            <div class={[
              "text-2xl font-bold",
              if(Decimal.positive?(@average_change), do: "text-[#198754]", else: "text-[#dc3545]")
            ]}>
              {format_percentage(@average_change)}
            </div>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  # Formatting helpers
  def format_currency(nil), do: "N/A"

  def format_currency(%Decimal{} = value) do
    "$#{Decimal.round(value, 2) |> Decimal.to_string()}"
  end

  def format_number(nil), do: "N/A"

  def format_number(value) when is_number(value) do
    Number.Delimit.number_to_delimited(value, precision: 0)
  end

  def format_market_value(nil), do: "N/A"

  def format_market_value(%Decimal{} = value) do
    billions = Decimal.div(value, Decimal.new("1000000000"))
    "$#{Decimal.round(billions, 2) |> Decimal.to_string()}B"
  end

  def format_change(nil, _), do: "N/A"
  def format_change(_, nil), do: "N/A"

  def format_change(%Decimal{} = change, %Decimal{} = pct) do
    change_sign = if Decimal.positive?(change), do: "+", else: "-"
    abs_change = Decimal.abs(change)

    pct_sign = if Decimal.positive?(pct), do: "+", else: "-"
    abs_pct = Decimal.abs(pct)

    "#{change_sign}$#{Decimal.round(abs_change, 2) |> Decimal.to_string()} (#{pct_sign}#{Decimal.round(abs_pct, 2) |> Decimal.to_string()}%)"
  end

  def value_color(value) do
    cond do
      String.starts_with?(value, "+") -> "text-[#198754]"
      String.starts_with?(value, "-") -> "text-[#dc3545]"
      true -> "text-[#212529]"
    end
  end

  defp format_percentage(%Decimal{} = value) do
    sign = if Decimal.positive?(value), do: "+", else: "-"
    abs_value = Decimal.abs(value)
    "#{sign}#{Decimal.round(abs_value, 2) |> Decimal.to_string()}%"
  end

  defp format_percentage(nil), do: "N/A"
end
