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

  # Browser routes - HTML pages
  scope "/", ProviderVaultWebWeb do
    pipe_through(:browser)

    get("/", PageController, :home)
    get("/providers", ProviderController, :index)
    get("/providers/:npi", ProviderController, :show)
    get("/faq", FAQController, :index)
    get("/symptoms", SymptomController, :index)
    get("/search", SearchController, :index)
  end

  # API routes - JSON endpoints
  scope "/api", ProviderVaultWebWeb do
    pipe_through(:api)

    # FAQ chatbot endpoint
    post("/faq/ask", FAQController, :ask)
    
    # Symptom search endpoint
    post("/symptoms/search", SymptomController, :search)
    
    # Natural language search endpoint
    get("/search/query", SearchController, :query)
  end
end
