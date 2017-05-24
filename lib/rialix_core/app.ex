defmodule RialixCore.App do
  @moduledoc """
  """
  use Application
  require Logger

  @doc """

  """
  def start(_start_type, _start_args) do
    maybe_delay_start()
    :ok = validate_ring_state_directory_exists()
    :ok = safe_register_cluster_info()
    :ok = add_bucket_deafults()

    start_riak_core_sup()
  end

  @doc """
  
  """
  def stop(_state) do
    Logger.info "Stopped application rialix_core."
    :ok
  end

  defp maybe_delay_start() do
    case Application.get_env :rialix_core, :delayed_start do
      {:ok, delay} ->
        Logger.info "Delaying rialix_core startup as requested"
        :timer.sleep delay
      _ ->
        :ok
    end
  end

end