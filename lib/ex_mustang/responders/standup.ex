defmodule ExMustang.Responders.Standup do
  @moduledoc """
  Module that sends message when its Standup time
  """

  import ExMustang.Utils

  @doc """
  Function to call for sending standup notice
  """
  def run do
    msg = %Hedwig.Message{
      type: "message",
      room: "#{config[:slack_channel]}",
      text: "@channel: #{config[:msg]}, #{Hedwig.Responder.random(config[:suffix])}!",
    }
    send(msg)
  end

  defp config, do: Application.get_env(:ex_mustang, ExMustang.Responders.Standup)
end
