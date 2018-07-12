defmodule ExMustang.Responders.InviteAll do
  @moduledoc """
  A responder to invite all the members of one channel to another channel
  """
  use Hedwig.Responder
  import ExMustang.Utils

  @usage """
  inviteall [src_channel] - invite all the members (of optionally source channel)
  """
  hear ~r/^inviteall$/i, msg do
    do_invite(msg.room)
  end

  hear ~r/^inviteall\s+(?<channel>\w+)$/i, msg do
    do_invite(msg.room, msg.matches["channel"])
  end

  defp do_invite(dest_channel, src_channel \\ nil) do
    src_channel
    |> members()
    |> Enum.each(fn m ->
      query = %{
        token: Application.get_env(:ex_mustang, __MODULE__)[:slack_token],
        channel: dest_channel,
        user: m["id"]
      }

      headers = [{"Content-Type", "text/plain"}]
      HedwigSlack.HTTP.post("/channels.invite", query: query, headers: headers)
    end)
  end
end
