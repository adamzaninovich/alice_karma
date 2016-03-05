# AliceKarma

This handler will allow Alice to keep track of karma points for arbitrary terms

## Installation

If [available in Hex](https://hex.pm/packages/alice_karma), the package can be
installed as:

  1. Add `alice_karma` to your list of dependencies in `mix.exs`:

    ```elixir
    defp deps do
      [
        {:websocket_client, github: "jeremyong/websocket_client"},
        {:alice, "~> 0.2.0"},
        {:alice_karma, "~> 0.1.0"}
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
