defmodule Alice.Handlers.Karma do
  use Alice.Router

  route ~r/\A([^\s]+)\+\+(?:(?=\s)|$)/i, :increment
  route ~r/\A([^\s]+)--(?:(?=\s)|$)/i,   :decrement
  route ~r/\A([^\s]+)~~(?:(?=\s)|$)/i,   :check

  command ~r/\bkarma best\z/i,           :best
  command ~r/\bkarma worst ?(?<amount>\d+)?\z/i, :worst
  command ~r/\bkarma clear ([^\s]+)\z/i, :clear

  def handle(conn, :increment) do
    term = term(conn)
    count = get_count(conn, term) + 1

    "#{term}: #{count}"
    |> reply(put_count(conn, term, count))
  end

  def handle(conn, :decrement) do
    term = term(conn)
    count = get_count(conn, term) - 1

    "#{term}: #{count}"
    |> reply(put_count(conn, term, count))
  end

  def handle(conn, :check) do
    term = term(conn)
    count = get_count(conn, term)

    "#{term}: #{count}" |> reply(conn)
  end

  def handle(conn, :best) do
    conn
    |> sorted_terms(&>=/2)
    |> reply(conn)
  end

  def handle(conn, :worst) do
    conn
    |> sorted_terms(&</2)
    |> reply(conn)
  end

  defp sorted_terms(conn, sort_fun) do
    get_counts(conn)
    |> Enum.sort_by(fn({_,val}) -> val end, sort_fun)
    |> Enum.take(5)
    |> Enum.with_index(1)
    |> Enum.map(fn({{term, val}, n}) -> "#{n}. #{term}: #{val}" end)
    |> Enum.join("\n")
  end

  defp get_count(conn, term, default \\ 0) do
    conn
    |> get_counts
    |> Map.get(term, default)
  end

  defp get_counts(conn) do
    get_state(conn, :karma_counts, %{})
  end

  defp put_count(conn, term, count) do
    counts = conn
             |> get_counts
             |> Map.put(term, count)
    put_state(conn, :karma_counts, counts)
  end

  defp term(conn) do
    [_full, term | _rest] = conn.message.captures
    String.downcase(term)
  end
end
