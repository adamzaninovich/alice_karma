defmodule AliceKarma.Mixfile do
  use Mix.Project

  def project do
    [app: :alice_karma,
     version: "0.3.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: "A handler for the Alice Slack bot. Allows Alice to keep track of karma points for arbitrary terms.",
     package: package,
     deps: deps]
  end

  def application do
    [applications: []]
  end

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:credo, ">= 0.0.0", only: :dev},
      {:alice, "~> 0.3"}
    ]
  end

  defp package do
    [files: ["lib", "config", "mix.exs", "README*"],
     maintainers: ["Adam Zaninovich"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/adamzaninovich/alice_karma",
              "Docs"   => "https://github.com/adamzaninovich/alice_karma"}]
  end
end
