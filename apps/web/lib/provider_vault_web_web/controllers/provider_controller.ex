defmodule ProviderVaultWebWeb.ProviderController do
  use ProviderVaultWebWeb, :controller

  alias ProviderVaultWeb.Providers

  def index(conn, params) do
    # Get page from URL params, default to 1
    page = String.to_integer(params["page"] || "1")

    # Get search term from URL params
    search = params["search"] || ""

    # Get specialty filter from URL params
    specialty = params["specialty"] || ""

    # Get list of all specialties for dropdown
    specialties = Providers.list_specialties()

    # Get state filter from URL params
    state = params["state"] || ""

    # Get list of all states for dropdown
    states = Providers.list_states()

    # Get paginated providers with search and specialty filter
    pagination =
      Providers.list_providers_paginated(
        page: page,
        per_page: 20,
        search: search,
        specialty: specialty,
        state: state
      )

    render(conn, :index,
      providers: pagination.providers,
      page: pagination.page,
      total_pages: pagination.total_pages,
      total: pagination.total,
      search: pagination.search,
      specialty: pagination.specialty,
      specialties: specialties,
      state: pagination.state,
      states: states
    )
  end

  def show(conn, %{"npi" => npi}) do
    case Providers.get_provider(npi) do
      nil ->
        conn
        |> put_flash(:error, "Provider not found")
        |> redirect(to: "/providers")

      provider ->
        render(conn, :show, provider: provider)
    end
  end
end
