defmodule ExMustang.Responders.CommitMsg do
  @moduledoc """
  Get random commit messages from http://whatthecommit.com/index.txt
  """
  use Hedwig.Responder
  import ExMustang.Utils, only: [useragent: 0]

  @url "http://whatthecommit.com/index.txt"

  @usage """
  commitmsg - get a random commit message
  """
  hear ~r/^commitmsg$/i, msg do
    reply(msg, get_commit_msg())
  end

  defp get_commit_msg do
    case HTTPoison.get(@url, [useragent()]) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body

      _ ->
        "I encountered problem getting commit message."
    end
  end
end
