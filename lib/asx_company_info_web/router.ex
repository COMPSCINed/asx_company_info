defmodule AsxCompanyInfoWeb.Router do
  use AsxCompanyInfoWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {AsxCompanyInfoWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", AsxCompanyInfoWeb do
    pipe_through :browser

    live "/", CompanyLive.Index, :index
    live "/compare", ComparisonLive.Index, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", AsxCompanyInfoWeb do
  #   pipe_through :api
  # end
end
