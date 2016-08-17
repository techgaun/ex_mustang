defmodule ExMustang.Robot do
  use Hedwig.Robot, otp_app: :ex_mustang

  def after_connect(state) do
    Hedwig.Registry.register(state.name)

    {:ok, state}
  end
end
