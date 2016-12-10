defmodule ExMustang.Responders.Slap do
  @moduledoc """
  Slap user on slack around a bit with a large trout

  `slap <username> | me
  """
  use Hedwig.Responder

  @emoticon ":fish:"
  # banters copied from https://github.com/spfr/slapbot/blob/master/helpers.js#L2-L19
  @banters [
    "Ouch! That must hurt!",
    "That should teach you a lesson!",
    "Ha ha ha ha!",
    "Damn milenial!",
    "Take that, you fool!",
    "Feel the pain!",
    "You probably still use Notepad++...",
    "Your pull request is horrible.",
    "Your JIRA ticket sucks.",
    "Your Trello card is lame. Do you even Markdown bro?",
    "Ooooh snap!",
    "Get slapped, son!",
    "Your bloody hipster!",
    "Now go back to work!",
    "Go buy us some Ice Cream!",
    "Why don’t you go back to your desk and tail call yourself?",
    "Are you a priest? Your code is running on pure faith and no logic…",
    "Your code, just like C, has no class!"
  ]

  @usage """
  slap - Slaps the user. Format: slap <username> | me
  """
  hear ~r/^slap\s*me/i, msg do
    emote msg, build_msg(msg.user.id)
    emote msg, random(@banters)
  end
  hear ~r/^slap\s*<@(?<user>\w+)>.*$/i, msg do
    emote msg, build_msg(msg.matches["user"])
    emote msg, random(@banters)
  end

  defp build_msg(user) do
    "slaps <@#{user}> around a bit with a large trout #{@emoticon}"
  end
end
