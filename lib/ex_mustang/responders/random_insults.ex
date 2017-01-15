defmodule ExMustang.Responders.RandomInsult do
  @moduledoc """
  Sends random insult to a user
  """
  use Hedwig.Responder
  import ExMustang.Utils, only: [useragent: 0]

  @base_url "http://www.randominsults.net/"

  @usage """
  insult me|<username> - insults given username with random insults
  """

  hear ~r/^insult\s*me$/i, msg do
    emote msg, insult(msg.user.id)
  end

  hear ~r/^insult\s?+<@(?<user>\w+)>.*$/i, msg do
    emote msg, insult(msg.matches["user"])
  end

  defp insult(user) do
    case HTTPoison.get(@base_url, [useragent()]) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        parse_body(body, user)
      _ ->
        "I can not insult #{user} right now"
    end
  end

  defp parse_body(body, user) do
    case Floki.find(body, "i") do
      [{"i", _, [msg]} | _] ->
        "<@#{user}> : #{msg}"
      _ ->
        "I am unable to parse insult data. Please let the author know his shit is broken!"
    end
  end
end
