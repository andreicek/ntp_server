defmodule NtpServerTest do
  use ExUnit.Case
  doctest NtpServer

  test "greets the world" do
    assert NtpServer.hello() == :world
  end
end
