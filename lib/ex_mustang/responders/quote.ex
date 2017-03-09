defmodule ExMustang.Responders.Quote do
  @moduledoc """
  Random Quote, FTW!

  Sends random message when someone says `quote`
  """
  use Hedwig.Responder
  import ExMustang.Utils

  @quotes_file Application.get_env(:ex_mustang, ExMustang.Responders.Quote)[:quote_src]
  @usage """
  quote - Replies with a random quote.
  """
  hear ~r/^quote(!)?$/i, msg do
    reply msg, random(quotes())
  end

  @doc """
  Function to call for sending random quote of the day
  """
  def run do
    conf = config()
    msg = %Hedwig.Message{
      type: "message",
      room: channel_id(conf[:slack_channel]),
      text: "<!channel> Quote of the day: " <> random(quotes())
    }
    send(msg)
  end

  defp quotes, do: @quotes_file |> File.read! |> String.split("\n")

  defp config, do: Application.get_env(:ex_mustang, ExMustang.Responders.Quote)
end
