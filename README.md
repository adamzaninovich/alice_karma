# AliceKarma [![Hex Version](https://img.shields.io/hexpm/v/alice_karma.svg)](https://hex.pm/packages/alice_karma) [![Deps Status](https://beta.hexfaktor.org/badge/all/github/alice-bot/alice_karma.svg)](https://beta.hexfaktor.org/github/alice-bot/alice_karma) [![Hex Downloads](https://img.shields.io/hexpm/dt/alice_karma.svg)](https://hex.pm/packages/alice_karma) [![License: MIT](https://img.shields.io/hexpm/l/alice_karma.svg)](https://hex.pm/packages/alice_karma)

This handler will allow Alice to keep track of karma points for arbitrary terms

## Installation

If [available in Hex](https://hex.pm/packages/alice_karma), the package can be
installed as:

  1. Add `alice_karma` to your list of dependencies in `mix.exs`:

    ```elixir
    defp deps do
      [
        {:websocket_client, github: "jeremyong/websocket_client"},
        {:alice, "~> 0.3"},
        {:alice_karma, "~> 0.1"}
      ]
    end
    ```

  2. Add the handler to your list of registered handlers in `mix.exs`:

    ```elixir
    def application do
      [applications: [:alice],
        mod: {
          Alice, [Alice.Handlers.Karma, ...]}]
    end
    ```

## Usage

Use `@alice help` for more information.
