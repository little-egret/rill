defmodule RialixCore.Application do
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
<<<<<<< HEAD:lib/rialix_core/app.ex

  defp maybe_delay_start() do
    case Application.get_env :rialix_core, :delayed_start do
      {:ok, delay} ->
        Logger.info "Delaying rialix_core startup as requested"
        :timer.sleep delay
      _ ->
        :ok
    end
  end

=======
>>>>>>> 900a855ec72b4a07e58a7e57c5e6bd6d594b97f9:lib/rialix_core/application.ex
end