# ex_mustang

> A simple, clueless bot (that does nothing much right now)

![Mustang](images/mustang.jpg)

ExMustang is a bot for Slack written in Elixir.

_Warning: This is a work in progress._

### Setup

Create a Slack bot user from [here](https://my.slack.com/services/new/bot). You will receive an API token you can use. Set the `SLACK_API_TOKEN` environment variable and you should be good to go.

You can run this bot as below:

```shell
export SLACK_API_TOKEN="<SLACK_API_TOKEN>"
mix run --no-halt
```

#### Github Pull Requests Watcher

You can configure github token by setting `GITHUB_TOKEN`. Also, you can pass list of repos to watch by updating [config](config/config.exs).

### Responders

```shell
<bot_nick> help - Displays help message
<bot_nick> quote - Displays random quote
```
