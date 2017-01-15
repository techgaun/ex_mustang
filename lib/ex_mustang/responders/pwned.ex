defmodule ExMustang.Responders.Pwned do
  @moduledoc """
  Search an account for pwnage results on haveibeenpwned.com
  """
  use Hedwig.Responder
  alias ExPwned.Breaches
  import ExMustang.Utils

  @usage """
  pwned <search_account> - Checks to see if an account has been breached or not
  """

  hear ~r/^pwned\s+(?<account>.*)$/i, msg do
    response = msg.matches["account"]
      |> norm_account
      |> build_msg
    reply msg, response
  end

  @doc """
  run/0 is supposed to be run via cron.
  """
  def run do
    pwned = config()[:accounts]
      |> Enum.reduce([], fn account, msgs ->
        msgs = case Breaches.breachedaccount(account) do
          {:ok, result, _} when length(result) > 0 ->
            ["Your account #{account} has been breached.\n\n#{list_result(result)}" | msgs]
          _ ->
            msgs
        end
        :timer.sleep(1_600)
        msgs
      end)

    if length(pwned) > 0 do
      pwned
      |> Enum.join("\n\n")
      |> send_msg
    end
  end

  defp send_msg(text) do
    msg = %Hedwig.Message{
      type: "message",
      room: channel_id(config()[:slack_channel]),
      text: text
    }
    send(msg)
  end

  defp build_msg(account) do
    case Breaches.breachedaccount(account) do
      {:ok, result, _} when length(result) > 0 ->
        "Oh no! Your account has been breached.\n\n#{list_result(result)}"
      {:ok, %{msg: "no breach was found for given input"}, _} ->
        "No need to worry. #{account} has not been breached so far."
      _ ->
        "I was unable to complete your request at this time. Please try again later"
    end
  end

  defp list_result(result) do
    result
    |> Stream.map(fn x ->
      "Your account was one of #{x["PwnCount"]} accounts on #{x["Name"]} breach leaked on #{x["BreachDate"]}"
    end)
    |> Enum.join("\n")
  end

  defp norm_account("<mailto:" <> mail) do
    [account | _] = String.split(mail, "|", parts: 2)
    account
  end
  defp norm_account(account), do: account

  defp config, do: Application.get_env(:ex_mustang, ExMustang.Responders.Pwned)
end
