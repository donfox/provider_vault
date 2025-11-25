defmodule ProviderVaultWebWeb.FAQController do
  use ProviderVaultWebWeb, :controller

  def index(conn, _params) do
    render(conn, :index)
  end

  def ask(conn, %{"question" => question} = params) do
    conversation_history = params["conversation_history"] || []
    
    # Call Python AI service
    case call_ai_service(question, conversation_history) do
      {:ok, result} ->
        json(conn, result)
      
      {:error, reason} ->
        conn
        |> put_status(:service_unavailable)
        |> json(%{error: reason})
    end
  end

  defp call_ai_service(question, conversation_history) do
    url = "http://localhost:8000/api/faq"
    headers = [{"Content-Type", "application/json"}]
    
    body = Jason.encode!(%{
      question: question,
      conversation_history: conversation_history
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
