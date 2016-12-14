defmodule ExMustang.Responders.TimeConvert do
  @moduledoc """
  Time conversion related stuff.
  """
  use Hedwig.Responder
  import ExMustang.Utils

  @usage """
  unix2iso <unix_timestamp> - Converts given unix timestamp to ISO format
  """
  hear ~r/^unix2iso\s+(?<ts>[0-9]{1,})$/i, msg do
    reply msg, convert(msg.matches["ts"])
  end

  defp convert(ts) when is_binary(ts) do
    ts
    |> String.to_integer
    |> convert(type(ts))
  end
  defp convert(ts, type) do
    ts
    |> DateTime.from_unix(type)
    |> case do
      {:ok, dt} ->
        iso = dt |> DateTime.to_iso8601
        "#{iso} (Assuming #{Atom.to_string(type)})"
      _ ->
        "Sorry, I could not parse that timestamp"
    end
  end

  defp type(ts) do
    cond do
      String.length(ts) >= 15 -> :microseconds
      String.length(ts) >= 12 -> :milliseconds
      true -> :seconds
    end
  end
end
