defmodule ExMustang.Responders.SensitiveLeak do
  @moduledoc """
  Listens to the user messages and tries to find if that message consists of anything sensitive
  """
  use Hedwig.Responder

  @usage """
  this responder acts automatically on each message
  """
  hear ~r//i, msg do
    reply msg, "initial test"
  end
end
