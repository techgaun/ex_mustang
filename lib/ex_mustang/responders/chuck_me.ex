defmodule ExMustang.Responders.ChuckMe do
  @moduledoc """
  Tells a random Chuck Norris joke from icndb.com
  """

  use Hedwig.Responder
  import ExMustang.Utils, only: [useragent: 0]

  @base_url "http://api.icndb.com/jokes/random"

  @usage """
  chuckme - tells a random Chuck Norris joke
  """

  hear ~r/^chuckme$/i, msg do
    emote(msg, get_joke())
  end

  defp get_joke() do
    case HTTPoison.get(@base_url, [useragent()]) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body
        |> Poison.decode!()
        |> extract_joke()

      _ ->
        "Chuck doesn't want to be bothered right now"
    end
  end

  defp extract_joke(%{"value" => %{"joke" => joke}}) do
    joke
  end

  defp extract_joke(_) do
    "Unable to parse the joke. Maybe it's too complex for mere mortals to understand!"
  end
end
