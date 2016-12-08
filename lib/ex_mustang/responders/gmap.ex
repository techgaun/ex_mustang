defmodule ExMustang.Responders.GMap do
  @moduledoc """
  Search places on Slack and get direct link to places by just typing `gmap <search term>`
  """
  alias ExGoogle.Places.Api, as: Places
  use Hedwig.Responder

  @usage """
  gmap <search_term> - Replies with the information from google places/maps.
  """
  hear ~r/^gmap (.*)$/i, msg do
    %Hedwig.Message{matches: %{1 => search_term}} = msg
    result = case Places.search(%{query: search_term}, :text) do
      {:ok, [%{"formatted_address" => _} = h | _]} ->
        IO.inspect h
        build_msg(h)
      _ ->
        "I could not find that place on google maps"
    end
    reply msg, result
  end

  defp build_msg(h) do
    "I found #{h["name"]}"
    |> build_msg(Map.delete(h, "name"))
  end
  defp build_msg(msg, %{"formatted_address" => addr} = h) do
    msg <> " at #{addr}"
    |> build_msg(Map.delete(h, "formatted_address"))
  end
  defp build_msg(msg, %{"rating" => rating} = h) do
    msg <> "\nThe rating for this place is #{rating}"
    |> build_msg(Map.delete(h, "rating"))
  end
  defp build_msg(msg, %{"opening_hours" => %{"open_now" => true}} = h) do
    msg <> "\nIt is open now"
    |> build_msg(Map.delete(h, "opening_hours"))
  end
  defp build_msg(msg, %{"opening_hours" => %{"open_now" => false}} = h) do
    msg <> "\nIt is closed now"
    |> build_msg(Map.delete(h, "opening_hours"))
  end
  defp build_msg(msg, %{"types" =>types} = h) do
    types = types
      |> Stream.filter(fn x -> not Enum.member?(["establishment", "point_of_interest"], x) end)
      |> Enum.join(", ")
    msg = if String.length(types) > 0 do
      msg <> "\nIt is labelled as : #{types}"
    else
      msg
    end
    msg
    |> build_msg(Map.delete(h, "types"))
  end
  defp build_msg(msg, _), do: msg
end
