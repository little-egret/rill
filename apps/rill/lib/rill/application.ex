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
    ClusterInfo.register_app(Rill.CinfoCore)
  catch
    _, _ ->
      :ok
  end

  defp add_bucket_deafults do
    Rill.Bucket.append_bucket_defaults(Rill.Bucket.Type.defaults(:default_type))
    :ok
  end

  defp start_rill_sup do
    case Rill.Supervisor.start_link do
      {:ok, pid} ->
        :ok = register_applications()
        :ok = add_ring_event_handler()
        
        :ok = register_capabilities()
        :ok = init_cli_registry()
        :ok = Rill.Throttle.init()

        {:ok, pid}
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp register_applications do
    Rill.register(:rill, [stat_mod: Rill.Stat,
                          permissions: [:get_bucket,
                                        :set_bucket,
                                        :get_bucket_type,
                                        :set_bucket_type]])
    :ok
  end

  defp add_ring_event_handler do
    :ok = Rill.add_guarded_handler(:rill_ring_handler, [])
  end

  defp init_cli_registry do
    Rill.Registry.load_schema()
    Rill.Registry.register_node_finder()
    Rill.Registry.register_cli()
    :ok
  end

@doc """
register_capabilities() ->
    Capabilities = [[{riak_core, vnode_routing},
                     [proxy, legacy],
                     legacy,
                     {riak_core,
                      legacy_vnode_routing,
                      [{true, legacy}, {false, proxy}]}],
                    [{riak_core, staged_joins},
                     [true, false],
                     false],
                    [{riak_core, resizable_ring},
                     [true, false],
                     false],
                    [{riak_core, fold_req_version},
                     [v2, v1],
                     v1],
                    [{riak_core, security},
                     [true, false],
                     false],
                    [{riak_core, bucket_types},
                     [true, false],
                     false],
                    [{riak_core, net_ticktime},
                     [true, false],
                     false]],
    lists:foreach(
      fun(Capability) ->
              apply(riak_core_capability, register, Capability)
      end,
      Capabilities),
    ok.
"""
  defp register_capabilities do
    :ok
  end

end
