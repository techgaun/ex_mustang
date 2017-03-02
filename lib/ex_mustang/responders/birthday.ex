defmodule ExMustang.Responders.Birthday do
  @moduledoc """
  Send birthday message to the user mentioned

  Quotes taken from https://github.com/github/hubot-scripts/blob/master/src/scripts/birthday.coffee
  """
  use Hedwig.Responder

  @msgs [
    "Happy Birthday {name}, you're not getting older, you're just a little closer to death.",
    "Birthdays are good for you {name}. Statistics show that people who have the most live the longest!",
    "{name} - Always remember: growing old is mandatory, growing up is optional. Happy Birthday!",
    "You always have such fun birthdays {name}, you should have one every year.",
    "Happy birthday to {name}, a person who is smart, good looking, and funny and reminds me a lot of myself.",
    "{name} - We know we're getting old when the only thing we want for our birthday is not to be reminded of it.",
    "Happy Birthday on your very special day {name}, I hope that you don't die before you eat your cake.",
    "{name} - Hoping that your day will be as special as you are.",
    "{name} - Count your life by smiles, not tears. Count your age by friends, not years.",
    "May the years continue to be good to you. Happy Birthday {name}!",
    "{name} - You're not getting older, you're getting better.",
    "{name} - May this year bring with it all the success and fulfillment your heart desires.",
    "{name} - Wishing you all the great things in life, hope this day will bring you an extra share of all that makes you happiest.",
    "Happy Birthday {name}, and may all the wishes and dreams you dream today turn to reality.",
    "May this day bring to you all things that make you smile. Happy Birthday {name}!",
    "{name} - Your best years are still ahead of you.",
    "{name} - Birthdays are filled with yesterday's memories, today's joys, and tomorrow's dreams.",
    "{name} - Hoping that your day will be as special as you are.",
    "{name} - You'll always be forever young."
  ]

  @usage """
  happy birthday <me|@user> - Send happy birthday message to the user mentioned
  """
  hear ~r/^happy\s?+birthday\s?+me.*$/i, msg do
    emote msg, get_birthday_msg(msg.user.id)
  end
  hear ~r/^happy\s?+birthday\s?+<@(?<user>\w+)>.*$/i, msg do
    emote msg, get_birthday_msg(msg.matches["user"])
  end

  defp get_birthday_msg(user) do
    @msgs
    |> random()
    |> String.replace("{name}", "<@#{user}>")
  end
end
