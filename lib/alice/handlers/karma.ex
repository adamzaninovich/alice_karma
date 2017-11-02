defmodule Alice.Handlers.Karma do
  @moduledoc """
  Allows Alice to keep track of karma points for arbitrary terms
  """

  use Alice.Router

  @default_denial_messages ["https://i.imgur.com/MWG4lMY.jpg",
                            "https://i.imgur.com/DGj9WX2.gif",
                            "https://i.imgur.com/J6j4QdA.gif",
                            "https://i.imgur.com/2yxg2lB.gif",
                            "https://i.imgur.com/A5iY5B9.gif",
                            "People who don't think shouldn't talk.",
                            "Yeah, nope."]
  @karma_denial_messages Application.get_env(:alice_karma, :karma_denial_messages, @default_denial_messages)

  route   ~r/\b([^\s;]+)\+\+(?:(?=\s)|$)/i, :increment
  route   ~r/\b([^\s;]+)--(?:(?=\s)|$)/i,   :decrement
  route   ~r/\b([^\s;]+)~~(?:(?=\s)|$)/i,   :check
  command ~r/>:? karma\z/i,                 :best
  command ~r/>:? karma best( \d+)?\z/i,     :best
  command ~r/>:? karma worst( \d+)?\z/i,    :worst
  command ~r/>:? karma empty ([^\s]+)\z/i,  :empty
  command ~r/>:? karma empty all the karma, and yes I actually really mean to do this!\z/i, :empty_all

  @doc "`term++` - increase the karma for a term but only if term does not equal incrementer's name"
  def increment(conn) do
    conn
    |> get_term
    |> increment(Alice.Conn.user(conn), conn)
  end

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
  def empty(conn), do: empty(conn, get_term(conn), Alice.Conn.user(conn))

  defp empty(conn, user, user), do: deny_karma(conn)
  defp empty(conn, term, _user) do
    count = get_count(conn, term)

    conn
    |> delete_count(term)
    |> reply("#{term}'s karma has been scattered to the winds. (#{count})")
  end

  defp increment(user, user, conn),  do: deny_karma(conn)
  defp increment(term, _user, conn), do: respond_with_change(term, conn, 1)

  defp deny_karma(conn), do: reply(conn, @karma_denial_messages)

  defp respond_with_change(conn, delta) do
    conn
    |> get_term()
    |> respond_with_change(conn, delta)
  end

  defp respond_with_change(term, conn, delta) when byte_size(term) > 1 do
    count = get_count(conn, term) + delta

    conn
    |> put_count(term, count)
    |> reply("#{term}: #{count}")
  end
  defp respond_with_change(_term, conn, _delta), do: conn

  defp respond_with_sorted_terms(conn, sort_func) do
    conn
    |> get_counts()
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
                      |> String.trim()
                      |> String.to_integer()
      _default     -> 5
    end
  end

  defp get_count(conn, term, default \\ 0) do
    conn
    |> get_counts()
    |> Map.get(term, default)
  end

  defp get_counts(conn) do
    get_state(conn, :karma_counts, %{})
  end

  defp put_count(conn, term, count) do
    counts = conn
             |> get_counts()
             |> Map.put(term, count)
    put_state(conn, :karma_counts, counts)
  end

  defp delete_count(conn, term) do
    counts = conn
             |> get_counts()
             |> Map.delete(term)
    put_state(conn, :karma_counts, counts)
  end

  defp get_term(conn) do
    [_full, term | _rest] = conn.message.captures
    String.downcase(term)
  end
end
