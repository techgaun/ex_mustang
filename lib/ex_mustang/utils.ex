defmodule ExMustang.Utils do
  @moduledoc """
  Module consisting of all the convenience functions for `ExMustang` to operate
  """

  @doc """
  Send a %Hedwig.Message{} struct through the robot process
  """
  @spec send(%Hedwig.Message{}) :: :ok
  def send(msg) do
    Hedwig.Robot.send(pid(), msg)
  end

  @doc """
  Gets the list of channels for Slack from Hedwig.Adapters.Slack process state
  """
  def channels do
    slack_state = get_slack_state()

    slack_state
    |> Map.get(:channels, %{})
    |> Map.merge(Map.get(slack_state, :groups, %{}))
  end

  @doc """
  Gets the channel ID from channel name
  """
  @spec channel_id(String.t()) :: String.t() | nil
  def channel_id(name) do
    {id, _} =
      channels()
      |> Stream.map(fn {_x, %{"id" => id, "name" => name}} -> {id, name} end)
      |> Enum.find({nil, nil}, fn {_, channel} -> channel === name end)

    id
  end

  @doc """
  Gets all the members in the slack team
  """
  @spec members() :: list
  def members do
    get_slack_state()
    |> Map.get(:users)
    |> Enum.reduce([], fn {_, member}, acc ->
      [member | acc]
    end)
  end

  @doc """
  Gets all the members in a given channel
  """
  @spec members(String.t() | nil) :: list
  def members(nil), do: members()

  def members(channel) do
    cid = channel_id(channel)

    channel =
      get_slack_state()
      |> Map.get(:channels)
      |> Map.get(cid)

    members()
    |> Enum.filter(fn member ->
      member["id"] in channel["members"]
    end)
  end

  def get_slack_state do
    %Hedwig.Robot{adapter: apid} = pid() |> :sys.get_state()

    apid
    |> :sys.get_state()
    |> Map.from_struct()
  end

  @doc false
  def useragent, do: {"User-Agent", "ExMustang"}

  @doc """
  Parses given domain based on how it comes. If it comes from slack, it is handled properly
  """
  def parse_domain(domain) do
    if String.contains?(domain, "<http") do
      [_ | [domain]] = String.split(domain, "|")
      String.trim_trailing(domain, ">")
    else
      domain
    end
  end

  defp pid, do: :global.whereis_name("mustang")
end
