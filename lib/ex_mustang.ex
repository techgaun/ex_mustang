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
    Quantum.add_job(:standup, %Quantum.Job{
      schedule: Application.get_env(:ex_mustang, ExMustang.Responders.Standup)[:time_of_day],
      task: fn -> ExMustang.Responders.Standup.run end
    })
  end
end
