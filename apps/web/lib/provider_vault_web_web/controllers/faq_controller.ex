defmodule ProviderVaultWebWeb.FAQController do
  use ProviderVaultWebWeb, :controller

  def index(conn, _params) do
    render(conn, :index)
  end

  def ask(conn, params) do
    case validate_faq_params(params) do
      {:ok, question, conversation_history} ->
        call_ai_service(conn, question, conversation_history)
      
      {:error, message} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: message})
    end
  end

  defp validate_faq_params(params) do
    question = params["question"]
    conversation_history = params["conversation_history"] || []

    cond do
      is_nil(question) or question == "" ->
        {:error, "Missing required parameter: question"}
      
      not is_list(conversation_history) ->
        {:error, "conversation_history must be an array"}
      
      true ->
        {:ok, question, conversation_history}
    end
  end

  defp call_ai_service(conn, question, conversation_history) do
    url = "http://localhost:8000/api/faq"
    headers = [{"Content-Type", "application/json"}]
    
    body = Jason.encode!(%{
      question: question,
      conversation_history: conversation_history
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
