defmodule ExMustang.Utils do
  @moduledoc """
  Module consisting of all the convenience functions for `ExMustang` to operate
  """

  @doc """
  Send a %Hedwig.Message{} struct through the robot process
  """
  @spec send(%Hedwig.Message{}) :: :ok
  def send(msg) do
    pid = :global.whereis_name("mustang")
    Hedwig.Robot.send(pid, msg)
  end
end
