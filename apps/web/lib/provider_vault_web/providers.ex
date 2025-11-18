defmodule ProviderVaultWeb.Providers do
  @moduledoc """
  The Providers context - handles all provider-related business logic.
  """

  import Ecto.Query, warn: false
  alias ProviderVaultWeb.Repo
  alias ProviderVaultWeb.Provider

  @doc """
  Returns the list of all providers.
  """
  def list_providers do
    Repo.all(Provider)
  end

  @doc """
  Returns a paginated list of providers with optional search.

  ## Examples

      iex> list_providers_paginated(page: 1, per_page: 10)
      %{providers: [...], total: 60, page: 1, per_page: 10, total_pages: 6}

      iex> list_providers_paginated(page: 1, per_page: 10, search: "smith")
      %{providers: [...], total: 5, page: 1, per_page: 10, total_pages: 1}

  """
  def list_providers_paginated(opts \\ []) do
    page = Keyword.get(opts, :page, 1)
    per_page = Keyword.get(opts, :per_page, 20)
    search = Keyword.get(opts, :search, "")
    specialty = Keyword.get(opts, :specialty, "")
    state = Keyword.get(opts, :state, "")

    # Calculate offset
    offset = (page - 1) * per_page

    # Build base query with optional search and specialty filter
    query =
      build_search_query(search)
      |> filter_by_specialty(specialty)
      |> filter_by_state(state)

    # Get total count
    total = Repo.aggregate(query, :count)

    # Get paginated providers
    providers =
      query
      |> order_by([p], asc: p.last_name, asc: p.first_name)
      |> limit(^per_page)
      |> offset(^offset)
      |> Repo.all()

    # Calculate total pages
    total_pages = ceil(total / per_page)

    %{
      providers: providers,
      page: page,
      per_page: per_page,
      total: total,
      total_pages: total_pages,
      search: search,
      specialty: specialty,
      state: state
    }
  end

  defp build_search_query(""), do: Provider

  defp build_search_query(search) when is_binary(search) do
    search_term = "%#{search}%"

    from(p in Provider,
      where:
        ilike(p.first_name, ^search_term) or
          ilike(p.last_name, ^search_term) or
          ilike(p.name, ^search_term) or
          ilike(p.npi, ^search_term)
    )
  end

  # Private function to filter by specialty
  defp filter_by_specialty(query, ""), do: query

  defp filter_by_specialty(query, specialty) when is_binary(specialty) do
    from(p in query, where: p.specialty == ^specialty)
  end

  # Private function to filter by state
  defp filter_by_state(query, ""), do: query

  defp filter_by_state(query, state) when is_binary(state) do
    from(p in query, where: p.state == ^state)
  end

  @doc """
  Gets a single provider by NPI.
  """
  def get_provider(npi) do
    Repo.get_by(Provider, npi: npi)
  end

  @doc """
  Returns the count of providers.
  """
  def count_providers do
    Repo.aggregate(Provider, :count)
  end

  @doc """
  Returns a list of all unique specialties in the database.
  """
  def list_specialties do
    Provider
    |> select([p], p.specialty)
    |> distinct(true)
    |> where([p], not is_nil(p.specialty))
    |> order_by([p], asc: p.specialty)
    |> Repo.all()
  end

  @doc """
  Returns a list of all unique states in the database.
  """
  def list_states do
    Provider
    |> select([p], p.state)
    |> distinct(true)
    |> where([p], not is_nil(p.state))
    |> order_by([p], asc: p.state)
    |> Repo.all()
  end
end
