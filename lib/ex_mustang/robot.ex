defmodule ExMustang.Robot do
  use Hedwig.Robot, otp_app: :ex_mustang

  def handle_connect(%{name: name} = state) do
    if :undefined == :global.whereis_name(name) do
      :yes = :global.register_name(name, self())
    end

    {:ok, state}
  end
end
