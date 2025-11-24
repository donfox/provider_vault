defmodule ProviderVaultWeb.AIClient do
  @moduledoc """
  HTTP client for communicating with the Python AI service.
  Includes automatic retry logic for transient failures.
  """

  @ai_service_url "http://localhost:8000"
  # 1 second
  @retry_delay 1000

  @doc """
  Get a patient-friendly description of a medical specialty.

  ## Examples

      iex> AIClient.describe_specialty("Cardiology")
      {:ok, "Cardiology focuses on the heart and..."}
  """
  def describe_specialty(specialty_name) do
    make_request_with_retry(
      fn ->
        HTTPoison.post(
          "#{@ai_service_url}/api/specialty/describe",
          Jason.encode!(%{specialty: specialty_name}),
          [{"Content-Type", "application/json"}],
          # 15 second timeout
          recv_timeout: 15_000
        )
      end,
      fn body ->
        case Jason.decode(body) do
          {:ok, %{"description" => description}} -> {:ok, description}
          _ -> {:error, "Invalid response format"}
        end
      end
    )
  end

  @doc """
  Get related specialties for a given specialty.
  """
  def suggest_related(specialty_name, num_suggestions \\ 3) do
    make_request_with_retry(
      fn ->
        HTTPoison.post(
          "#{@ai_service_url}/api/specialty/related",
          Jason.encode!(%{specialty: specialty_name, num_suggestions: num_suggestions}),
          [{"Content-Type", "application/json"}],
          recv_timeout: 15_000
        )
      end,
      fn body ->
        case Jason.decode(body) do
          {:ok, %{"related_specialties" => specialties}} -> {:ok, specialties}
          _ -> {:error, "Invalid response format"}
        end
      end
    )
  end

  @doc """
  Check if the AI service is available.
  """
  def health_check do
    case HTTPoison.get("#{@ai_service_url}/health", [], recv_timeout: 5_000) do
      {:ok, %HTTPoison.Response{status_code: 200}} -> :ok
      _ -> :error
    end
  end

  # Private helper function to handle retries
  defp make_request_with_retry(request_fn, parse_fn, attempt \\ 1) do
    case request_fn.() do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        parse_fn.(body)

      {:ok, %HTTPoison.Response{status_code: status}} ->
        if attempt < 2 do
          # Retry once for 500-level errors
          if status >= 500 do
            Process.sleep(@retry_delay)
            make_request_with_retry(request_fn, parse_fn, attempt + 1)
          else
            {:error, "AI service returned status #{status}"}
          end
        else
          {:error, "AI service returned status #{status}"}
        end

      {:error, %HTTPoison.Error{reason: :timeout}} ->
        if attempt < 2 do
          # Retry once on timeout
          Process.sleep(@retry_delay)
          make_request_with_retry(request_fn, parse_fn, attempt + 1)
        else
          {:error, "Request timed out after 2 attempts"}
        end

      {:error, %HTTPoison.Error{reason: reason}} ->
        if attempt < 2 do
          # Retry once on connection errors
          Process.sleep(@retry_delay)
          make_request_with_retry(request_fn, parse_fn, attempt + 1)
        else
          {:error, "Connection error: #{reason}"}
        end
    end
  end
end
