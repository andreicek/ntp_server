defmodule NtpServer.BitstringSigil do
  def sigil_b(string, _opts) do
    string
    |> String.upcase()
    |> String.split("\n")
    |> Enum.map(&String.split(&1, " "))
    |> List.flatten()
    |> Enum.reject(&(&1 == ""))
    |> Enum.join()
    |> Base.decode16!()
  end
end
