defmodule ExMustang.Scheduler do
  use Quantum.Scheduler,
    otp_app: :ex_mustang

  alias Crontab.CronExpression.Parser, as: CronParser
  alias __MODULE__

  require Logger

  @spec add_job(String.t, Crontab.Expression.t, (() -> any) | tuple()) :: Quantum.Job.t
  def add_job(name, expr, task) do
    Logger.info "Creating cronjob #{name} with expression #{inspect expr} and task definition: #{inspect task}"
    expr = if is_binary(expr), do: CronParser.parse!(expr), else: expr
    Scheduler.new_job()
    |> Quantum.Job.set_name(name)
    |> Quantum.Job.set_schedule(expr)
    |> Quantum.Job.set_task(task)
    |> Scheduler.add_job()
  end
end
