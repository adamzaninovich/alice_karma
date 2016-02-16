defmodule Alice.Handlers.Karma do
  use Alice.Router

  route ~r/\A([^\s]+)\+\+(?:(?=\s)|$)/i, :increment
  route ~r/\A([^\s]+)--(?:(?=\s)|$)/i,   :decrement
  route ~r/\A([^\s]+)~~(?:(?=\s)|$)/i,   :check

  command ~r/\bkarma\z/i,                :best
  command ~r/\bkarma best( \d+)?\z/i,    :best
  command ~r/\bkarma worst( \d+)?\z/i,   :worst
  command ~r/\bkarma empty\z/i,          :empty_all
  command ~r/\bkarma empty ([^\s]+)\z/i, :empty

  def handle(conn, :increment), do: respond_with_change(conn, 1)
  def handle(conn, :decrement), do: respond_with_change(conn, -1)
  def handle(conn, :check),     do: respond_with_change(conn, 0)
  def handle(conn, :best),      do: respond_with_sorted_terms(conn, &>=/2)
  def handle(conn, :worst),     do: respond_with_sorted_terms(conn, &</2)
  def handle(conn, :empty_all) do
    "All karma has been scattered to the winds."
    |> reply(delete_state(conn, :karma_counts))
  end
  def handle(conn, :empty) do
    term = term(conn)

    "#{term} has had its karma scattered to the winds."
    |> reply(delete_count(conn, term))
  end

  defp respond_with_change(conn, delta) do
    term = term(conn)
    count = get_count(conn, term) + delta

    "#{term}: #{count}"
    |> reply(put_count(conn, term, count))
  end

  defp respond_with_sorted_terms(conn, sort_fun) do
    get_counts(conn)
    |> Enum.sort_by(fn({_,count}) -> count end, sort_fun)
    |> Enum.take(get_amount(conn))
    |> Enum.with_index(1)
    |> Enum.map(fn({{term,count},n}) -> "#{n}. #{term}: #{count}" end)
    |> Enum.join("\n")
    |> reply(conn)
  end

  defp get_amount(conn) do
    case conn.message.captures do
      [_,amount|_] -> amount
                      |> String.strip
                      |> String.to_integer
      _default     -> 5
    end
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

  defp delete_count(conn, term) do
    counts = conn
             |> get_counts
             |> Map.delete(term)
    put_state(conn, :karma_counts, counts)
  end

  defp term(conn) do
    [_full, term | _rest] = conn.message.captures
    String.downcase(term)
  end
end
