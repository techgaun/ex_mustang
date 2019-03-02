defmodule ExMustang.Responders.Uptime do
  @moduledoc """
  Run uptime check against list of endpoints
  """

  import ExMustang.Utils

  def run do
    config()[:endpoints]
    |> Stream.map(&endpoint_check(&1))
    |> Stream.filter(&(length(&1) > 0))
    |> Enum.map(&Enum.join(&1, "\n"))
    |> case do
      [_ | _] = result ->
        result |> Enum.join("\n\n") |> send_msg()
      _ -> :ok
    end
  end

  defp endpoint_check(ep) do
    method = (ep[:method] || "get") |> String.to_atom()
    headers = ep[:req_headers] || []
    timeout = ep[:timeout] || 10_000
    http_opts = [timeout: timeout, recv_timeout: timeout]
    req_body = ep[:body] || ""

    case HTTPoison.request(method, ep[:uri], req_body, headers, http_opts) do
      {:ok, %HTTPoison.Response{body: body, headers: resp_headers, status_code: sc}} ->
        {_, actual_ctype} = List.keyfind(resp_headers, "Content-Type", 0, {nil, nil})

        msg =
          if status_code_good?(ep[:status_code], sc),
            do: [],
            else: ["HTTP Status Code mismatched: #{sc}(Actual) / #{ep[:status_code]}(Expected)"]

        msg = if body_good?(ep[:content], body), do: msg, else: ["Response body mismatched" | msg]

        msg =
          if content_type_good?(ep[:content_type], actual_ctype),
            do: msg,
            else: [
              "Content Type mismatched: #{actual_ctype}(Actual) / #{ep[:content_type]}(Expected)"
              | msg
            ]

        msg = msg |> Enum.reverse()
        if length(msg) > 0, do: ["Uptime check for #{ep[:uri]} failed" | msg], else: msg

      {:error, %HTTPoison.Error{reason: reason}} ->
        []
        # need to do something about this
        # ["I encountered an error while performing uptime check on #{ep[:uri]} with reason: #{reason}"]
    end
  end

  defp status_code_good?(nil, _), do: true
  defp status_code_good?(expected, actual), do: expected === actual

  defp body_good?(nil, _), do: true

  defp body_good?(expected, actual) do
    if Regex.regex?(expected) do
      Regex.match?(expected, actual)
    else
      String.contains?(actual, expected)
    end
  end

  defp content_type_good?(nil, _), do: true
  defp content_type_good?(_, nil), do: false
  defp content_type_good?(expected, actual), do: String.contains?(actual, expected)

  defp send_msg(text) do
    msg = %Hedwig.Message{
      type: "message",
      room: channel_id(config()[:slack_channel]),
      text: text
    }

    send(msg)
  end

  defp config, do: Application.get_env(:ex_mustang, __MODULE__)
end
