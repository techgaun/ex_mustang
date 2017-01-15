defmodule ExMustang.Responders.GitTip do
  @moduledoc """
  Gives git tips to user.
  The git-tips are taken from https://github.com/git-tips/tips/blob/master/tips.json
  """

  import ExMustang.Utils, only: [useragent: 0]
  use Hedwig.Responder

  @tip_json "https://raw.githubusercontent.com/git-tips/tips/master/tips.json"
  @tmpfile "#{System.tmp_dir}/git-tip-exmustang.json"

  @usage """
  gittip [keyword] - Get a random git tip for given keyword
  """
  hear ~r/^gittip$/i, msg do
    reply msg, (read_json() |> get_random())
  end
  hear ~r/^gittip\s+(?<keyword>.*)$/i, msg do
    reply msg, get_tip(msg.matches["keyword"])
  end

  def get_random(lst) do
    lst
    |> Enum.take_random(1)
    |> hd
    |> format_msg
  end

  def get_tip(keyword) do
    keyword_lower = String.downcase(keyword)
    read_json()
    |> Enum.filter(fn x ->
      haystack = String.downcase(x["title"])
      String.contains?(haystack, keyword_lower)
    end)
    |> case do
      [] ->
        "I could not find any git tips for : #{keyword}"
      result ->
        result
        |> get_random
    end
  end

  def format_msg(tip) do
    msg = "*#{tip["title"]}*\n`#{tip["tip"]}`"
    if is_list(tip["alternatives"]) do
      alts = tip["alternatives"]
        |> Enum.join("\n")
      "#{msg}\nAlternatively, you can use following:\n```#{alts}```"
    else
      msg
    end
  end

  def read_json do
    unless recent_json?(), do: download_json()

    @tmpfile
    |> File.read!()
    |> Poison.decode!
  end

  def recent_json? do
    if File.exists?(@tmpfile) do
      mtime = File.stat!(@tmpfile).mtime
      Timex.diff(Timex.now, mtime, :hours) < 24
    else
      false
    end
  end

  def download_json do
    %HTTPoison.Response{body: json} = HTTPoison.get!(@tip_json, [useragent()], follow_redirect: true)
    File.write!(@tmpfile, json)
  end
end
