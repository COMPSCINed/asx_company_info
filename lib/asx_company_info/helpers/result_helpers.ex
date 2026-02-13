defmodule Helpers.ResultHelpers do
  @type result :: {:ok, term()} | {:error, term()}

  @spec bind(result(), (term() -> result())) :: result()
  def bind(result, func) do
    case result do
      {:ok, success} ->
        func.(success)

      error ->
        error
    end
  end

  @spec map(result(), (term() -> term())) :: result()
  def map(result, func) do
    case result do
      {:ok, success} ->
        {:ok, func.(success)}

      error ->
        error
    end
  end

  @spec map_error(result(), (term() -> term())) :: result()
  def map_error(result, func) do
    case result do
      {:error, error} ->
        {:error, func.(error)}

      success ->
        success
    end
  end
end
