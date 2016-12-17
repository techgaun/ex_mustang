defmodule ExMustang.Responders.CLIFu do
  @moduledoc """
  A commandlinefu.com responder that gets cli goodies
  """
  use Hedwig.Responder
  import ExMustang.Utils, only: [useragent: 0]

  @base_url "http://www.commandlinefu.com/commands"
  @random_url "#{@base_url}/random/json"
  @search_url "#{@base_url}/matching"

  @usage """
  clifu [search_word] - get clifu gem (gives random clifu if no keyword is passed)
  """
  hear ~r/^clifu$/i, msg do
    reply msg, fetch_clifu(@random_url)
  end
  hear ~r/^clifu\s+(?<query>\w+)$/i, msg do
    clifu = msg.matches["query"]
      |> build_url
      |> fetch_clifu

    reply msg, clifu
  end

  defp build_url(query) do
    "#{@search_url}/#{query}/#{Base.encode64(query)}/sort-by-votes/json"
  end

  defp fetch_clifu(url) do
    case HTTPoison.get(url, [useragent], follow_redirect: true) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body
        |> Poison.decode!
        |> extract_clifu
      _ ->
        "I encountered problem getting clifu."
    end
  end

  defp extract_clifu(%{"command" => cmd, "summary" => summary, "url" => url}) do
    "#{summary}\n```#{cmd}```\nSource: #{url}"
  end
  defp extract_clifu(clifus) when is_list(clifus) do
    [clifu] = Enum.take_random(clifus, 1)
    extract_clifu(clifu)
  end
end
