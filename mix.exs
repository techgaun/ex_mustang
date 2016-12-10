defmodule ExMustang.Mixfile do
  use Mix.Project

  def project do
    [app: :ex_mustang,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :hedwig_slack, :quantum, :tentacat, :ex_google, :timex],
     mod: {ExMustang, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:hedwig_slack, "~> 1.0"},
      {:tentacat, "~> 0.5"},
      {:quantum, "~> 1.8.1"},
      {:timex, "~> 3.1"},
      {:ex_google, "~> 0.1"}
    ]
  end
end
