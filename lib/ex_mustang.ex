defmodule ExMustang do
  use Application

  alias ExMustang.Scheduler

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      # Starts a worker by calling: ExMustang.Worker.start_link(arg1, arg2, arg3)
      # worker(ExMustang.Worker, [arg1, arg2, arg3]),
      worker(ExMustang.Robot, []),
      worker(ExMustang.Scheduler, [])
    ]

    add_jobs()
    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ExMustang.Supervisor]
    {:ok, sup_pid} = Supervisor.start_link(children, opts)
    add_jobs()
    {:ok, sup_pid}
  end

  def add_jobs do
    standup_config = Application.get_env(:ex_mustang, ExMustang.Responders.Standup)

    if standup_config[:enabled] do
      Scheduler.add_job(
        :standup,
        standup_config[:time_of_day],
        fn -> ExMustang.Responders.Standup.run() end
      )
    end

    gh_config = Application.get_env(:ex_mustang, ExMustang.Responders.Github)

    if gh_config[:enabled] do
      Scheduler.add_job(
        :github_pr,
        gh_config[:schedule],
        fn -> ExMustang.Responders.Github.run() end
      )
    end

    pwned_config = Application.get_env(:ex_mustang, ExMustang.Responders.Pwned)

    if pwned_config[:enabled] do
      Scheduler.add_job(
        :pwned_check,
        pwned_config[:schedule],
        fn -> ExMustang.Responders.Pwned.run() end
      )
    end

    uptime_config = Application.get_env(:ex_mustang, ExMustang.Responders.Uptime)

    if uptime_config[:enabled] do
      Scheduler.add_job(
        :uptime_check,
        uptime_config[:schedule],
        fn -> ExMustang.Responders.Uptime.run() end
      )
    end

    quote_config = Application.get_env(:ex_mustang, ExMustang.Responders.Quote)

    if quote_config[:enabled] do
      Scheduler.add_job(
        :quote_of_the_day,
        quote_config[:schedule],
        fn -> ExMustang.Responders.Quote.run() end
      )
    end
  end
end
