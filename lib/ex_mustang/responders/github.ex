defmodule ExMustang.Responders.Github do
  @moduledoc """
  Retrieves list of open PRs in provided repos, compares the time they are open
  and sends message about the PRs that are open for too long.
  """

  import ExMustang.Utils

  def run do
    gh_client = Tentacat.Client.new(%{access_token: config()[:access_token]})

    config()[:repos]
    |> Enum.each(fn x ->
      [usr, repo] = String.split(x, "/")

      Tentacat.Pulls.list(usr, repo, gh_client)
      |> Enum.each(fn x ->
        process_pr(x)
      end)
    end)
  end

  def process_pr(pr) do
    state = pr["state"]

    if state === "open" do
      link = pr["html_url"]

      created_time =
        pr["created_at"]
        |> Timex.parse!("{ISO:Extended}")

      updated_time =
        pr["updated_at"]
        |> Timex.parse!("{ISO:Extended}")

      current_time = Timex.now()
      created_diff = Timex.diff(current_time, created_time, :seconds)
      updated_diff = Timex.diff(current_time, updated_time, :seconds)

      if updated_diff > config()[:updated_time_threshold] and
           created_diff > config()[:created_time_threshold] do
        title = pr["title"]
        text = "<!channel> PR #{title}(#{link}) is open since a while. You better be watching it!"
        send_msg(text)
      end
    end
  end

  def send_msg(text) do
    msg = %Hedwig.Message{
      type: "message",
      room: channel_id(config()[:slack_channel]),
      text: text
    }

    send(msg)
  end

  defp config, do: Application.get_env(:ex_mustang, ExMustang.Responders.Github)
end
