defmodule ExMustang.Responders.Isup do
  @moduledoc """
  checks against https://isitup.org/<domain>.json if the given site is down or not
  """
  use Hedwig.Responder

  @usage """
  isitup <domain> - checks if given domain is up or not
  """

  hear ~r/^isitup\s+(?<domain>.*)$/i, msg do
    reply msg, isitup(msg.matches["domain"])
  end

  def isitup(domain) do
    domain = parse_domain(domain)
    case HTTPoison.get("https://isitup.org/#{domain}.json") do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body = Poison.decode!(body)
        case body["status_code"] do
          1 -> "#{domain} is up and running."
          2 -> "#{domain} looks down to me."
          3 -> "#{domain} looks like an invalid domain."
          _ -> "I could not check status of #{domain}"
        end
      _ ->
        "Could not check if #{domain} is up or not. Please try later"
    end
  end

  defp parse_domain(domain) do
    if String.contains?(domain, "<http") do
      [_ | [domain]] = String.split(domain, "|")
      String.trim_trailing(domain, ">")
    else
      domain
    end
  end
end
