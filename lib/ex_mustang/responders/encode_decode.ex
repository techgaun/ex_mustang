defmodule ExMustang.Responders.EncodeDecode do
  @moduledoc """
  Encode/Decode module that can perform generic encoding/decoding
  """
  use Hedwig.Responder

  @usage """
  b64encode <content> - base64 encoding of given text content
  """
  hear ~r/^b64encode\s+(?<content>.*)$/i, msg do
    reply msg, Base.encode64(msg.matches["content"])
  end

  @usage """
  b64decode <content> - base64 decoding of given text content
  """
  hear ~r/^b64decode\s+(?<content>.*)$/i, msg do
    reply msg, b64_decode(msg.matches["content"])
  end

  # not sure if uri(en|de)code is actually useful.
  # TODO : decide on this
  # @usage """
  # uriencode <content> - URI encoding of given text content
  # """
  # hear ~r/^uriencode\s+(?<content>.*)$/i, msg do
  #   reply msg, msg.matches["content"] |> String.trim |> URI.encode
  # end
  #
  # @usage """
  # uridecode <content> - URI decoding of given text content
  # """
  # hear ~r/^uridecode\s+(?<content>.*)$/i, msg do
  #   reply msg, msg.matches["content"] |> String.trim |> URI.decode
  # end

  def b64_decode(content) do
    case Base.decode64(content) do
      {:ok, decoded} -> decoded
      :error -> "I don't think that was base64 encoded text"
    end
  end
end
