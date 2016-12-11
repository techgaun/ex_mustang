defmodule ExMustang.Utils do
  @moduledoc """
  Module consisting of all the convenience functions for `ExMustang` to operate
  """

  @doc """
  Send a %Hedwig.Message{} struct through the robot process
  """
  @spec send(%Hedwig.Message{}) :: :ok
  def send(msg) do
    Hedwig.Robot.send(pid, msg)
  end

  @doc """
  Gets the list of channels for Slack from Hedwig.Adapters.Slack process state
  """
  def channels do
    %Hedwig.Robot{adapter: apid} = :sys.get_state(pid)
    slack_state = apid
    |> :sys.get_state
    |> Map.from_struct

    slack_state
    |> Map.get(:channels, %{})
    |> Map.merge(Map.get(slack_state, :groups, %{}))
  end

  @doc """
  Gets the channel ID from channel name
  """
  @spec channel_id(String.t) :: String.t | nil
  def channel_id(name) do
    {id, _} = channels
      |> Stream.map(fn {_x, %{"id" => id, "name" => name}} -> {id, name} end)
      |> Enum.find({nil, nil}, fn {_, channel} -> channel === name end)
    id
  end

  defp pid, do: :global.whereis_name("mustang")
end
