defmodule ExMustang.Responders.Howdoi do
  @moduledoc """
  Implements [howdoi](https://github.com/gleitz/howdoi) like functionality
  """
  use Hedwig.Responder

  @google_base_url "https://www.google.com/search?q=site:stackoverflow.com%20"
  @ua [
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/53.0.2785.143 Chrome/53.0.2785.143 Safari/537.36",
    "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:50.0) Gecko/20100101 Firefox/50.0",
    "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:50.0) Gecko/20100101 Firefox/50.0",
    "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:48.0) Gecko/20100101 Firefox/48.0"
  ]

  @usage """
  howdoi <query> - tries to find solution on the given query
  """

  hear ~r/^howdoi\s+(?<query>.*)$/i, msg do
    reply msg, gsearch(msg.matches["query"])
  end

  defp gsearch(query) do
    [ua] = Enum.take_random(@ua, 1)
    case HTTPoison.get("#{@google_base_url}#{URI.encode(query)}", [{"User-Agent", ua}]) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        parse_gsearch(body)
      _ ->
        "I encountered an error while trying to fetch result for that query"
    end
  end

  defp parse_gsearch(body) do
    if String.contains?(body, "did not match any documents.") do
      no_result()
    else
      [so_url | _] = body
        |> Floki.find(".r a")

      so_url
      |> Floki.attribute("href")
      |> hd
      |> so_extract
    end
  end

  defp so_extract(so_url) do
    [ua] = Enum.take_random(@ua, 1)
    case HTTPoison.get(so_url, [{"User-Agent", ua}]) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        extract_code(body)
      _ ->
        "I encountered an error while trying to fetch result for that query"
    end
  end

  defp extract_code(body) do
    answers = Floki.find(body, "div#answers div.answer")
    case answers do
      [first | _] ->
        [answer | _] = first
          |> Floki.find("div.post-text")

         author =
          first
          |> Floki.find(".user-info .user-details")

          upvotes = first
                    |> Floki.find("div.vote span.vote-count-post")
                    |> Floki.text()

        get_data_to_send(answer, author, upvotes)

      _ ->
        no_result()
    end
  end

  defp get_data_to_send(post_block, author_block, upvotes) do
    code = post_block
      |> Floki.find("pre code")

    case code do
      [code | _] ->
        "#{build_author_text(author_block, upvotes)}\n```\n#{Floki.text(code)}```"
      [] ->
        "#{build_author_text(author_block, upvotes)}\n```\n#{Floki.text(post_block)}\n```"
      _ ->
        no_result()
    end
  end

  defp build_author_text(author_block, upvotes) do
    author_name = author_block 
                  |> Floki.find("a")
                  |> Floki.text()
    rep = author_block
          |> Floki.find("span.reputation-score")
          |> Floki.text()

    "This answer was written by #{author_name} (reputation #{rep}) and received #{upvotes} upvotes."
  end

  defp no_result, do: "Sorry! I could not find anything for your query"
end
