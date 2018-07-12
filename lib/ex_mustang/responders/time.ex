defmodule ExMustang.Responders.Time do
  @moduledoc """
  Gives back time based on the given timezone

  `time [timezone]`
  """
  use Hedwig.Responder

  @usage """
  time - get time in a given timezone
  """
  hear ~r/^time$/i, msg do
    reply(msg, build_msg())
  end

  hear ~r/^time\s+(?<tz>.*)$/i, msg do
    reply(msg, build_msg(msg.matches["tz"]))
  end

  defp build_msg(tz \\ :local) do
    now = tz |> Timex.now()

    case now do
      %DateTime{} ->
        time = now |> Timex.format!("%A, %d %b %Y %l:%M %p", :strftime)
        "Current time is: #{time}"

      _ ->
        "I don't recognize the timezone: #{tz}. Eg. tz are CST, America/Chicago, Asia/Kathmandu"
    end
  end
end
