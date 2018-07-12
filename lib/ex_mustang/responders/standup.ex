defmodule ExMustang.Responders.Standup do
  @moduledoc """
  Module that sends message when its Standup time
  """

  import ExMustang.Utils

  @doc """
  Function to call for sending standup notice
  """
  def run do
    conf = config()

    msg = %Hedwig.Message{
      type: "message",
      room: channel_id(conf[:slack_channel]),
      text: "<!channel> #{conf[:msg]}, #{Hedwig.Responder.random(conf[:suffix])}!"
    }

    send(msg)
  end

  defp config, do: Application.get_env(:ex_mustang, ExMustang.Responders.Standup)
end
