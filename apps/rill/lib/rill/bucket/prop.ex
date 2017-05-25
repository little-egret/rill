defmodule Rill.Bucket.Prop do
  @moduledoc """
  
  """

  @doc """
  append_defaults(Items) when is_list(Items) ->
      OldDefaults = app_helper:get_env(riak_core, default_bucket_props, []),
      NewDefaults = merge(OldDefaults, Items),
      FixedDefaults = case riak_core:bucket_fixups() of
          [] -> NewDefaults;
          Fixups ->
              riak_core_ring_manager:run_fixups(Fixups, default, NewDefaults)
      end,
      application:set_env(riak_core, default_bucket_props, FixedDefaults),
      %% do a noop transform on the ring, to make the fixups re-run
      catch(riak_core_ring_manager:ring_trans(fun(Ring, _) ->
                                                      {new_ring, Ring}
                                              end, undefined)),
      ok.
  """
  @spec append_defaults([{atom, any}]) :: :ok
  def append_defaults(items) when is_list(items) do
    old_defaults = Application.get_env(:rill, :default_bucket_props, [])
    new_defaults = merge(old_defaults, items)
    fixed_defaults = case Rill.bucket_fixups() do
      [] -> new_defaults
      fixups ->
        Rill.RingManager.run_fixups(fixups, default, new_defaults)
    end
    Application.put_env(:rill, :default_bucket_props, fixed_defaults)
  
    ## I don't know how to do with erlang `catch`
    Rill.RingManager.ring_trans(fn ring, _ ->
                                    {:new_ring, ring}
                                end, nil)
    :ok
  end
  
end