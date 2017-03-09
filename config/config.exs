# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :ex_mustang, ExMustang.Responders.Standup,
  time_of_day: "30 10 * * 1-5",
  slack_channel: System.get_env("STANDUP_CHANNEL") || "general",
  suffix: ["folks", "hackers", "peeps", "avengers"],
  msg: "Standup time",
  enabled: true

config :ex_mustang, ExMustang.Responders.Github,
  repos: ["techgaun/ex_mustang"],
  access_token: System.get_env("GITHUB_TOKEN"),
  schedule: "0 */1 * * *",
  slack_channel: System.get_env("GH_CHANNEL") || "general",
  created_time_threshold: 10800, # no old than 3 hours
  updated_time_threshold: 3600, # no old than 1 hour
  enabled: true

config :ex_mustang, ExMustang.Responders.Quote,
  quote_src: "files/quotes.txt",
  schedule: "1 10 * * *",
  slack_channel: System.get_env("QUOTE_CHANNEL") || "general",
  enabled: true

config :ex_mustang, ExMustang.Responders.Pwned,
  schedule: "59 23 */1 * *",
  enabled: true,
  accounts: [
    "abc@example.com",
    "def@example.com"
  ],
  slack_channel: System.get_env("PWN_CHANNEL") || "general"

config :ex_mustang, ExMustang.Responders.Uptime,
  schedule: "*/5 * * * *",
  enabled: true,
  endpoints: [
    [
      uri: "https://api.brighterlink.io/status", status_code: 200, content: ~s("msg":"ok"), method: "GET",
      content_type: "application/json", req_headers: [{"User-Agent", "ExMustang"}], timeout: 20_000
    ]
  ],
  slack_channel: System.get_env("UPTIME_CHANNEL") || "general"

config :ex_mustang, ExMustang.Responders.HerokuDeploy,
  github_token: System.get_env("HEROKU_GITHUB_TOKEN") || System.get_env("GITHUB_TOKEN"),
  token: System.get_env("HEROKU_TOKEN"),
  apps: [
    {"casa-core-stage", %{repo: "casaiq/core", branch: "master"}}
  ]

config :ex_mustang, ExMustang.Robot,
  adapter: Hedwig.Adapters.Slack,
  name: "mustang",
  aka: "/",
  token: System.get_env("SLACK_API_TOKEN"),
  responders: [
    {Hedwig.Responders.Help, []},
    {ExMustang.Responders.GMap, []},
    {ExMustang.Responders.Pwned, []},
    {ExMustang.Responders.Quote, []},
    {ExMustang.Responders.Slap, []},
    {ExMustang.Responders.Time, []},
    {ExMustang.Responders.TimeConvert, []},
    {ExMustang.Responders.EncodeDecode, []},
    {ExMustang.Responders.Isup, []},
    {ExMustang.Responders.RandomInsult, []},
    {ExMustang.Responders.HTTPCat, []},
    {ExMustang.Responders.Howdoi, []},
    {ExMustang.Responders.CommitMsg, []},
    {ExMustang.Responders.CLIFu, []},
    {ExMustang.Responders.Whois, []},
    {ExMustang.Responders.GitTip, []},
    {ExMustang.Responders.Birthday, []},
    {ExMustang.Responders.HerokuDeploy, []}
  ]

config :quantum, timezone: System.get_env("SYSTEM_TIME") || "America/Chicago"

config :ex_google,
  api_key: System.get_env("GOOGLE_API_KEY"),
  output: "json"


# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure for your application as:
#
#     config :ex_mustang, key: :value
#
# And access this configuration in your application as:
#
#     Application.get_env(:ex_mustang, :key)
#
# Or configure a 3rd-party app:
#
#     config :logger, level: :info
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env}.exs"
