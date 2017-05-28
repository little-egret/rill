defmodule Rill do
  @moduledoc """
  Documentation for Rill.
  """

  @doc """

  """
  def bucket_fixups do
    case Application.get_env(:rill, :bucket_fixups) do
      nil  -> []
      mods -> mods
    end
  end

  @doc """
  Register a named riak_core application.

  Once the app is registered, do a no-op ring trans
  to ensure the new fixups are run against
  the ring.
  """
  def register(_app, []) do
    {:ok, _r} = Rill.Ring.Manager.ring_trans(fn(r, _a) -> {:new_ring, r} end,
                                             nil)
    Rill.Ring.Events.force_sync_update()
    :ok
  end
  def register(app, [{:stat_mod, stat_mod}|t]) do
    register_mod(app, stat_mod, :stat_mods)
    register(app, t)
  end
  def register(app, [{:permissions, permissions}|t]) do
    register_mod(app, permissions, :permissions)
    register(app, t)
  end

  defp register_mod(app, module, type) when is_atom(type) do
    case type do
      :vnode_modules ->
        Rill.Vnode.Proxy.Supervisor.start_proxies(module)
      :stat_mods ->
        Rill.Stats.Supervisor.start_server(module)
      _ ->
        :ok
    end
    case Application.get_env(:rill, type) do
      nil ->
        Application.put_env(:rill, type, [{app, module}])
      {:ok, mods} ->
        Application.put_env(:rill, type,
          :lists.usort([{app, module}|mods]))
    end
  end
end
