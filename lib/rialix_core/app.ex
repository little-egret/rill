defmodule RialixCore.App do
  @moduledoc """
  """
  use Application

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

  
end