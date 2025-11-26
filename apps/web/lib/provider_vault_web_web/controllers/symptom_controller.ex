defmodule ProviderVaultWebWeb.SymptomController do
  use ProviderVaultWebWeb, :controller

  def index(conn, _params) do
    render(conn, :index)
  end

  def search(conn, %{"symptoms" => symptoms} = params) do
    location_state = params["location_state"]
    
    case call_ai_service(symptoms, location_state) do
      {:ok, result} ->
        json(conn, result)
      
      {:error, reason} ->
        conn
        |> put_status(:service_unavailable)
        |> json(%{error: reason})
    end
  end

  defp call_ai_service(symptoms, location_state) do
    url = "http://localhost:8000/api/symptoms/recommend"
    headers = [{"Content-Type", "application/json"}]
    
    body = Jason.encode!(%{
      symptoms: symptoms,
      location_state: location_state
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
