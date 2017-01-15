defmodule ExMustang.Responders.Isup do
  @moduledoc """
  checks against https://isitup.org/<domain>.json if the given site is down or not
  """
  use Hedwig.Responder
  import ExMustang.Utils, only: [useragent: 0, parse_domain: 1]

  @usage """
  isitup <domain> - checks if given domain is up or not
  """

  hear ~r/^isitup\s+(?<domain>.*)$/i, msg do
    reply msg, isitup(msg.matches["domain"])
  end

  def isitup(domain) do
    domain = parse_domain(domain)
    case HTTPoison.get("https://isitup.org/#{domain}.json", [useragent()]) do
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
end
