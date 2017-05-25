defmodule Rill.Application do
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

    start_rill_sup
  end

  @doc """

  """
  def stop(_state) do
    Logger.info "Stopped application rill."
    :ok
  end

  defp maybe_delay_start() do
    case Application.get_env :rill, :delayed_start do
      nil ->
        :ok
      delay ->
        Logger.info "Delaying rill startup as requested"
        :timer.sleep delay
    end
  end

  defp safe_register_cluster_info do
    ClusterInfo.register_app :rill_cinfo_core
  catch
    _, _ ->
      :ok
  end

  defp add_bucket_defaults do
    :default_type
    |> Rill.Bucket.Type.defaults()
    |> Rill.Bucket.append_bucket_defaults()

    :ok
  end

  defp start_rill_sup do
    case Rill.Supervisor.start_link do
      {:ok, pid} ->
        :ok = register_applications
        :ok = add_ring_event_handler

        :ok = register_capabilities
        :ok = init_cli_registry
        :ok = Rill.Throttle.init

        {:ok, pid}
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp validate_ring_state_directory_exists do
    ring_state_dir = Application.get_env(:rill, :ring_state_dir)
    with {:ok, _} <- Application.ensure_all_started(:rill),
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