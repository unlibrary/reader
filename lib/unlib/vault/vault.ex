defmodule UnLib.Vault do
  @moduledoc false
  use Cloak.Vault, otp_app: :unlib

  @impl GenServer
  def init(config) do
    config = Keyword.put(config, :ciphers, ciphers())
    {:ok, config}
  end

  defp ciphers() do
    [
      default: {
        Cloak.Ciphers.AES.GCM,
        tag: "AES.GCM.V1", key: decode_env!("CLOAK_KEY"), iv_length: 12
      }
    ]
  end

  defp decode_env!(var) do
    var
    |> System.get_env()
    |> Base.decode64!()
  end
end
