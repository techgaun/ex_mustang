defmodule ExMustang.Responders.Giphy do
  @moduledoc """
  Grabs a random gif from Giphy
  """
  use Hedwig.Responder
  import ExMustang.Utils, only: [useragent: 0]

  @random_gif_url "https://api.giphy.com/v1/gifs/random"
  @translate_gif_url "https://api.giphy.com/v1/gifs/translate"
  @api_key Application.get_env(:ex_mustang, ExMustang.Responders.Giphy)[:api_key]

  @usage """
  giphy [search_term] - Tries to find a GIF matching search_term (gives random gif if no search_term is provided)
  """

  hear ~r/^giphy\s?(?<tag>.*)$/i, msg do
    response =
      msg.matches["tag"]
      |> get_gif()

    reply(msg, response)
  end

  @doc """
  Get random GIF to show
  """
  def get_gif("") do
    case @random_gif_url
         |> URI.parse()
         |> Map.put(:query, URI.encode_query(%{api_key: @api_key, rating: "g"}))
         |> URI.to_string()
         |> HTTPoison.get([useragent()]) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body
        |> Poison.decode!()
        |> extract_gif()

      _ ->
        "Giphy not available right now"
    end
  end

  @doc """
  Get translated GIF to show
  """
  def get_gif(string) do
    case @translate_gif_url
         |> URI.parse()
         |> Map.put(:query, URI.encode_query(%{api_key: @api_key, s: string}))
         |> URI.to_string()
         |> HTTPoison.get([useragent()]) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body
        |> Poison.decode!()
        |> extract_gif()

      _ ->
        "Giphy not available right now"
    end
  end

  defp extract_gif(%{"data" => %{"images" => %{"downsized" => %{"url" => image_url}}}}) do
    image_url
  end

  defp extract_gif(_) do
    "Unable to parse the gif. Maybe it just wasn't a good match."
  end
end
