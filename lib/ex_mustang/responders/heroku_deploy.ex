defmodule ExMustang.Responders.HerokuDeploy do
  @moduledoc """
  Deploys an app from github to heroku

  For heroku deployment to work, you need to specify the following configurations:

  - `HEROKU_GITHUB_TOKEN` or `GITHUB_TOKEN`
  - `HEROKU_TOKEN` which is an API key you can get from [here](https://dashboard.heroku.com/account)
  - mapping of apps in your config which is a tuple of heroku app name and map of repo and branch

  An example config looks like below:

      config :ex_mustang, ExMustang.Responders.HerokuDeploy,
        github_token: System.get_env("HEROKU_GITHUB_TOKEN") || System.get_env("GITHUB_TOKEN"),
        token: System.get_env("HEROKU_TOKEN"),
        apps: [
          {"casa-core-stage", %{repo: "casaiq/core", branch: "master"}}
        ]
  """
  use Hedwig.Responder

  @headers [
    {"accept", "application/vnd.heroku+json; version=3"},
    {"content-type", "application/json"},
    {"user-agent", "ExMustang"}
  ]

  @usage """
  hdeploy <app-name> - Deploys configured branch to the given app
  """
  hear ~r/^hdeploy\s+(?<app_name>.*)$/i, msg do
    reply(msg, deploy(msg.matches["app_name"]))
  end

  defp deploy(app) do
    app_detail = Enum.find(config()[:apps], fn {a, _} -> a === app end)

    if is_nil(app_detail) do
      "I could not find #{app} in your configuration. Make sure you specify the app with repo and branch"
    else
      do_deploy(app_detail)
    end
  end

  defp do_deploy({app, detail}) do
    gh_client = Tentacat.Client.new(%{access_token: config()[:github_token]})
    [owner, repo] = String.split(detail[:repo], "/")
    branch = detail[:branch] || "master"

    case Tentacat.Repositories.Branches.find(owner, repo, branch, gh_client) do
      %{"commit" => %{"sha" => hash}} ->
        {302, location} =
          Tentacat.Repositories.Contents.archive_link(owner, repo, "tarball", branch, gh_client)

        heroku_request(app, hash, location)

      _ ->
        "I could not find #{branch} for #{app} in #{detail[:repo]}."
    end
  end

  defp heroku_request(app, hash, source) do
    payload = %{
      source_blob: %{url: source, version: hash}
    }

    ep = "https://api.heroku.com/apps/#{app}/builds"

    case HTTPoison.post(
           ep,
           Poison.encode!(payload),
           @headers ++ [{"authorization", "Bearer #{config()[:token]}"}]
         ) do
      {:ok, %HTTPoison.Response{status_code: 201}} ->
        "I started deploying #{app} with commit hash #{hash}. Enjoy!!!"

      _ ->
        "I could not deploy #{app}"
    end
  end

  defp config, do: Application.get_env(:ex_mustang, __MODULE__)
end
