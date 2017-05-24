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

  defp validate_ring_state_directory_exists do
    ring_state_dir = Application.get_env(:rialix_core, :ring_state_dir)
    with {:ok, _} <- Application.ensure_all_started(:rialix_core),
         :ok      <- :filelib.ensure_dir(Path.join(ring_state_dir, "dummy"))
    do
      :ok
    else
      {:error, {app, reason}} ->
        Logger.error ("Application :#{app} failed to start, reason:\n" <> inspect(reason))
        throw({:error, :failed_to_start_dependencies})
      {:error, ring_reason} ->
        Logger.error "Ring state directory #{ring_state_dir} does not exist, and could not be created: #{:lager.posix_error(ring_reason)}"
        throw({:error, :invalid_ring_state_dir})
    end
  end
end