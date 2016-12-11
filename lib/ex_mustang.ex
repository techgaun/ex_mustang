defmodule ExMustang do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      # Starts a worker by calling: ExMustang.Worker.start_link(arg1, arg2, arg3)
      # worker(ExMustang.Worker, [arg1, arg2, arg3]),
      worker(ExMustang.Robot, [])
    ]
    add_jobs()
    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ExMustang.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def add_jobs do
    standup_config = Application.get_env(:ex_mustang, ExMustang.Responders.Standup)
    if standup_config[:enabled] do
      Quantum.add_job(:standup, %Quantum.Job{
        schedule: standup_config[:time_of_day],
        task: fn -> ExMustang.Responders.Standup.run end
      })
    end

    gh_config = Application.get_env(:ex_mustang, ExMustang.Responders.Github)
    if gh_config[:enabled] do
      Quantum.add_job(:github_pr, %Quantum.Job{
        schedule: gh_config[:schedule],
        task: fn -> ExMustang.Responders.Github.run end
      })
    end

    pwned_config = Application.get_env(:ex_mustang, ExMustang.Responders.Pwned)
    if pwned_config[:enabled] do
      Quantum.add_job(:pwned_check, %Quantum.Job{
        schedule: pwned_config[:schedule],
        task: fn -> ExMustang.Responders.Pwned.run end
      })
    end

    uptime_config = Application.get_env(:ex_mustang, ExMustang.Responders.Uptime)
    if uptime_config[:enabled] do
      Quantum.add_job(:uptime_check, %Quantum.Job{
        schedule: uptime_config[:schedule],
        task: fn -> ExMustang.Responders.Uptime.run end
      })
    end
  end
end
