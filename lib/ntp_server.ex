defmodule NtpServer.UdpServer do
  require Logger
  use GenServer
  import NtpServer.BitstringSigil

  @ntp_constant 2_208_988_800

  def start_link(params) do
    GenServer.start_link(__MODULE__, params, name: __MODULE__)
  end

  def init(_params) do
    Logger.info("Starting server...")

    {:ok, socket} = :gen_udp.open(123, [:binary, {:active, false}])

    {:ok, socket, {:continue, :loop}}
  end

  def handle_continue(:loop, socket) do
    case :gen_udp.recv(socket, 0) do
      {:ok, :udp_closed} ->
        Logger.warning("UDP socket closed")

      {:error, reason} ->
        Logger.error("Error: #{reason}")

      {:ok, request} ->
        handle_request(socket, request)
        {:noreply, socket, {:continue, :loop}}
    end
  end

  ###

  defp handle_request(socket, {ip, port, request}) do
    Logger.info("Got UDP request")

    packet = generate_ntp_response(request)

    :gen_udp.send(socket, ip, port, packet)
  end

  def generate_ntp_response(<<_::binary-size(40), origin_timestamp::binary>> = _request) do
    now = System.system_time(:second)

    receive_timestamp = now
    transmit_timestamp = receive_timestamp

    header = ~b(24 02 03 E7) <> <<0::size(364)>>
    id = ~b(56 17 C3 1E)
    reference_timestamp = <<receive_timestamp + @ntp_constant::size(32), 0::size(32)>>
    origin_timestamp = origin_timestamp
    receive_timestamp = <<receive_timestamp + @ntp_constant::size(32), 0::size(32)>>
    transmit_timestamp = <<transmit_timestamp + @ntp_constant::size(32), 0::size(32)>>

    <<header::binary, id::binary, reference_timestamp::binary, origin_timestamp::binary,
      receive_timestamp::binary, transmit_timestamp::binary>>
  end
end
