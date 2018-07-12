defmodule ExMustang.Responders.HTTPCat do
  @moduledoc """
  Gets a HTTP Status Code Cat of https://http.cat
  """
  use Hedwig.Responder

  @base_url "https://http.cat"
  @known_codes [
    100,
    101,
    200,
    201,
    202,
    204,
    206,
    207,
    300,
    301,
    302,
    303,
    304,
    305,
    307,
    400,
    401,
    402,
    403,
    404,
    405,
    406,
    408,
    409,
    410,
    411,
    412,
    413,
    414,
    415,
    416,
    417,
    418,
    420,
    421,
    422,
    423,
    424,
    425,
    426,
    429,
    431,
    444,
    450,
    451,
    500,
    502,
    503,
    504,
    506,
    507,
    508,
    509,
    511,
    599
  ]

  @usage """
  httpcat <status_code> - get http status code cat for given value
  """

  hear ~r/^httpcat\s+(?<status_code>\w+).*$/i, msg do
    reply(msg, http_cat(msg.matches["status_code"]))
  end

  def http_cat(status_code) when is_binary(status_code) do
    case Integer.parse(status_code) do
      {v, _} ->
        http_cat(v)

      _ ->
        "you stupid! bad request\n#{http_cat(400)}"
    end
  end

  def http_cat(status_code) when status_code in @known_codes do
    "#{@base_url}/#{status_code}.jpg"
  end

  def http_cat(_) do
    "Can not find that status code\n#{@base_url}/404.jpg"
  end
end
