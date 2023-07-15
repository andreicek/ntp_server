defmodule NtpServer.Application do
  use Application

  def start(_type, _args) do
    children = [
      NtpServer.UdpServer
    ]

    opts = [strategy: :one_for_one, name: NtpServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
