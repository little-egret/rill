defmodule Rill.Application do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  def start(_type, _args) do
    maybe_delay_start()
    :ok = validate_ring_state_directory_exists()
    :ok = safe_register_cluster_info()
    :ok = add_bucket_deafults()

    start_rill_sup()
  end

  defp maybe_delay_start do
    case Application.get_env :rill, :delayed_start do
      nil ->
        :ok
      delay ->
        Logger.info "Delaying rill startup as requested."
        Process.sleep delay
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
        Logger.error "Ring state directory #{ring_state_dir} does not exist, and could not be created: #{inspect ring_reason}"
        throw({:error, :invalid_ring_state_dir})
    end
  end

  defp safe_register_cluster_info do
    ClusterInfo.register_app(:"Elixir.Rill.CinfoCore")
  catch
    _, _ ->
      :ok
  end

  defp add_bucket_deafults do
    Rill.Bucket.append_bucket_defaults(Rill.Bucket.Type.defaults(:default_type))
    :ok
  end

  defp start_rill_sup do
    {:ok, self()}
  end

end
