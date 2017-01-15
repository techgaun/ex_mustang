defmodule ExMustang.Responders.Whois do
  @moduledoc """
  Uses dnsquery.org to get whois information for given domain
  """
  use Hedwig.Responder
  import ExMustang.Utils, only: [useragent: 0, parse_domain: 1]

  @base_url "https://dnsquery.org/whois,request"

  @usage """
  whois <domain> - gives whois query for given domain
  """
  hear ~r/^whois\s+(?<domain>.*)$/i, msg do
    reply msg, whois(msg.matches["domain"])
  end

  defp whois(domain) do
    domain = domain
      |> parse_domain
      |> String.replace(~r|https?://|, "")

    case HTTPoison.get("#{@base_url}/#{domain}", [useragent()], follow_redirect: true) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body
        |> Floki.find("pre")
        |> parse_record(domain)
      _ ->
        "I could not perform whois on #{domain}"
    end
  end

  defp parse_record([], domain), do: "I did not find whois data for #{domain}."
  defp parse_record(record, domain) do
    data = record
      |> Floki.text
      |> String.trim
    if String.length(data) === 0 do
      "I could not find whois data for #{domain}"
    else
      "```\n#{data}```"
    end
  end
end
