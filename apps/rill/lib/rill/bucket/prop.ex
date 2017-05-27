defmodule Rill.Bucket.Prop do
  @moduledoc """
  
  """

  @doc """
  
  """
  @spec merge([{atom, any}], [{atom, any}]) :: [{atom, any}]
  def merge(overriding, other) do
    :lists.ukeymerge(1, :lists.ukeysort(1, overriding),
                     :lists.ukeysort(1, other))
  end

  @doc """

  """
  @spec append_defaults([{atom, any}]) :: :ok
  def append_defaults(items) when is_list(items) do
    old_defaults = Application.get_env(:rill, :default_bucket_props, [])
    new_defaults = merge(old_defaults, items)
    fixed_defaults = case Rill.bucket_fixups() do
      [] -> new_defaults
      fixups ->
        Rill.Ring.Manager.run_fixups(fixups, :default, new_defaults)
    end
    Application.put_env(:rill, :default_bucket_props, fixed_defaults)
  
    ## I don't know how to do with erlang `catch`
    Rill.Ring.Manager.ring_trans(fn ring, _ ->
                                    {:new_ring, ring}
                                end, nil)
    :ok
  end
  
end