defmodule Alice.Handlers.Karma do
  @moduledoc """
  Allows Alice to keep track of karma points for arbitrary terms
  """

  use Alice.Router

  route   ~r/\b([^\s]+)\+\+(?:(?=\s)|$)/i, :increment
  route   ~r/\b([^\s]+)--(?:(?=\s)|$)/i,   :decrement
  route   ~r/\b([^\s]+)~~(?:(?=\s)|$)/i,   :check
  command ~r/\bkarma\z/i,                  :best
  command ~r/\bkarma best( \d+)?\z/i,      :best
  command ~r/\bkarma worst( \d+)?\z/i,     :worst
  command ~r/\bkarma empty all the karma, and yes I actually really mean to do this!\z/i, :empty_all
  command ~r/\bkarma empty ([^\s]+)\z/i,   :empty

  @doc "`term++` - increase the karma for a term"
  def increment(conn), do: respond_with_change(conn, 1)

  @doc "`term--` - decrease the karma for a term"
  def decrement(conn), do: respond_with_change(conn, -1)

  @doc "`term~~` - check the karma for a term"
  def check(conn), do: respond_with_change(conn, 0)

  @doc "`karma best 10` - get the top terms (amount is optional)"
  def best(conn), do: respond_with_sorted_terms(conn, &>=/2)

  @doc "`karma worst 10` - get the lowest terms (amount is optional)"
  def worst(conn), do: respond_with_sorted_terms(conn, &</2)

  @doc "`karma empty all the karma and yes I actually really mean to do this` - clear the karma for all terms"
  def empty_all(conn) do
    conn
    |> delete_state(:karma_counts)
    |> reply("All karma has been scattered to the winds.")
  end

  @doc "`karma empty term` - clear the karma for a single term"
  def empty(conn) do
    term = get_term(conn)

    conn
    |> delete_count(term)
    |> reply("#{term} has had its karma scattered to the winds.")
  end

  defp respond_with_change(conn, delta) do
    term = get_term(conn)
    count = get_count(conn, term) + delta

    conn
    |> put_count(term, count)
    |> reply("#{term}: #{count}")
  end

  defp respond_with_sorted_terms(conn, sort_func) do
    conn
    |> get_counts
    |> Enum.sort_by(fn({_,count}) -> count end, sort_func)
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

  defp get_term(conn) do
    [_full, term | _rest] = conn.message.captures
    String.downcase(term)
  end
end
