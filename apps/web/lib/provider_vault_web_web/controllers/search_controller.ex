defmodule ProviderVaultWebWeb.SearchController do
  use ProviderVaultWebWeb, :controller

  def index(conn, _params) do
    render(conn, :index)
  end

  def query(conn, %{"q" => query, "limit" => limit}) do
    case call_ai_service(query, limit) do
      {:ok, result} ->
        json(conn, result)
      
      {:error, reason} ->
        conn
        |> put_status(:service_unavailable)
        |> json(%{error: reason})
    end
  end

  defp call_ai_service(query, limit) do
    url = "http://localhost:8000/api/search"
    headers = [{"Content-Type", "application/json"}]
    
    body = Jason.encode!(%{
      query: query,
      limit: String.to_integer(limit)
    })
    
    case HTTPoison.post(url, body, headers) do
      {:ok, %{status_code: 200, body: response_body}} ->
        {:ok, Jason.decode!(response_body)}
      
      {:ok, %{status_code: status_code}} ->
        {:error, "AI service returned status #{status_code}"}
      
      {:error, %{reason: reason}} ->
        {:error, "Failed to connect to AI service: #{reason}"}
    end
  end
end
