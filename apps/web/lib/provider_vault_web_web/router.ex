defmodule ProviderVaultWebWeb.Router do
  use ProviderVaultWebWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, html: {ProviderVaultWebWeb.Layouts, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", ProviderVaultWebWeb do
    pipe_through(:browser)

    get("/", PageController, :home)
    get("/providers", ProviderController, :index)
    get("/providers/:npi", ProviderController, :show)
    get("/faq", FAQController, :index)
  end

  scope "/api", ProviderVaultWebWeb do
    pipe_through(:api)
  end

  scope "/faq", ProviderVaultWebWeb do
    pipe_through(:api)
    post("/ask", FAQController, :ask)
  end
end
