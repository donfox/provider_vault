defmodule ProviderVaultWebWeb.SearchController do
  use ProviderVaultWebWeb, :controller

  def index(conn, _params) do
    render(conn, :index)
  end

  def query(conn, params) do
    case validate_search_params(params) do
      {:ok, query, limit} ->
        call_ai_service(conn, query, limit)
      
      {:error, message} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: message})
    end
  end

  defp validate_search_params(params) do
    query = params["q"]
    limit_str = params["limit"] || "20"

    cond do
      is_nil(query) or query == "" ->
        {:error, "Missing required parameter: q"}
      
      true ->
        case Integer.parse(limit_str) do
          {limit, _} when limit > 0 and limit <= 100 ->
            {:ok, query, limit}
          
          {limit, _} ->
            {:error, "Parameter 'limit' must be between 1 and 100, got: #{limit}"}
          
          :error ->
            {:error, "Parameter 'limit' must be a valid integer, got: #{limit_str}"}
        end
    end
  end

  defp call_ai_service(conn, query, limit) do
    url = "http://localhost:8000/api/search"
    headers = [{"Content-Type", "application/json"}]
    
    body = Jason.encode!(%{
      query: query,
      limit: limit
    })
    
    case HTTPoison.post(url, body, headers) do
      {:ok, %{status_code: 200, body: response_body}} ->
        json(conn, Jason.decode!(response_body))
      
      {:ok, %{status_code: status_code}} ->
        conn
        |> put_status(:service_unavailable)
        |> json(%{error: "AI service returned status #{status_code}"})
      
      {:error, %{reason: reason}} ->
        conn
        |> put_status(:service_unavailable)
        |> json(%{error: "Failed to connect to AI service: #{reason}"})
    end
  end
end
