defmodule ExMustang.Responders.UrbanDictionary do
  @moduledoc """
  Grabs word of the day from urban dictionary
  """
  use Hedwig.Responder
  import ExMustang.Utils, only: [useragent: 0]

  @feed_url "http://feeds.urbandictionary.com/UrbanWordOfTheDay"

  @usage """
  urbandictionary | udict - Gets word of the day from urbandictionary
  """

  hear ~r/^udict$/i, msg do
    reply(msg, get_ub_wotd())
  end
  hear ~r/^urbandictionary$/i, msg do
    reply(msg, get_ub_wotd())
  end

  def get_ub_wotd() do
    case HTTPoison.get(@feed_url, [useragent()]) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Fiet.parse(body) do
          {:ok, %Fiet.Feed{items: items}} ->
            "Word of the day is `#{hd(items).title}`\n#{hd(items).link}"

          _ ->
            "Urban Dictionary not available right now"
        end

      _ ->
        "Urban Dictionary not available right now"
    end
  end
end
