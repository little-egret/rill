defmodule RialixCore.Application do
  @moduledoc """
  """
  use Application
  require Logger

  @doc """

  """
  def start(_start_type, _start_args) do
    maybe_delay_start
    :ok = validate_ring_state_directory_exists
    :ok = safe_register_cluster_info
    :ok = add_bucket_deafults

    start_rialix_core_sup
  end

  @doc """

  """
  def stop(_state) do
    Logger.info "Stopped application rialix_core."
    :ok
  end

  defp maybe_delay_start() do
    case Application.get_env :rialix_core, :delayed_start do
      nil ->
        :ok
      delay ->
        Logger.info "Delaying rialix_core startup as requested"
        :timer.sleep delay
    end
  end

  defp safe_register_cluster_info do
    ClusterInfo.register_app :rialix_core_cinfo_core
  catch
    _, _ ->
      :ok
  end

  defp add_bucket_defaults do
    :default_type
    |> RialixCore.Bucket.Type.defaults()
    |> RialixCore.Bucket.append_bucket_defaults()

    :ok
  end

  defp start_rialix_core_sup do
    case RialixCore.Supervisor.start_link do
      {:ok, pid} ->
        :ok = register_applications
        :ok = add_ring_event_handler

        :ok = register_capabilities
        :ok = init_cli_registry
        :ok = RialixCore.Throttle.init

        {:ok, pid}
      {:error, reason} ->
        {:error, reason}
    end
  end

end