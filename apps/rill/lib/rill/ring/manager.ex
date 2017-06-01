defmodule Rill.Ring.Manager do
  @moduledoc """

  """
  require Logger
  use GenServer

  @doc """

  """
  def run_fixups([], _bucket, bucket_props) do
    bucket_props
  end
  def run_fixups([{app, fixup}|t], bucket_name, bucket_props) do
    bp = try do
      case apply(fixup, :fixup, [bucket_name, bucket_props]) do
        {:ok, new_bucket_props} ->
          new_bucket_props
        {:error, reason} ->
          Logger.error "Error while running bucket fixup module " <>
              "#{fixup} from application #{app} on bucket #{bucket_name}: #{reason}"
          bucket_props
      end
    catch
      what, why ->
        Logger.error "Crash while running bucket fixup module " <>
              "#{fixup} from application #{app} on bucket #{bucket_name}: #{what}:#{why}"
        bucket_props
    end
    run_fixups(t, bucket_name, bp)
  end

  @doc """

  """
  def ring_trans(fun, args) do
    GenServer.call(__MODULE__, {:ring_trans, fun, args}, :infinity)
  end

  def handle_call({:ring_trans, fun, args}, _, state=%state{raw_ring: ring}) do
    case fun.(ring, args) do
      {:new_ring, new_ring} ->
        state2 = prune_write_notify_ring(new_ring, state)
        Rill.Gossip.random_recursive_gossip(new_ring)
        {:reply, {:ok, new_ring}, state2}
      {:set_only, new_ring} ->
        state2 = prune_write_ring(new_ring, state)
        {:reply, {:ok, new_ring}, state2}
      {:reconciled_ring, new_ring} ->
        state2 = prune_write_notify_ring(new_ring, state)
        Rill.Gossip.recursive_gossip(new_ring)
        {:reply, {:ok, new_ring}, state2}
      :ignore ->
        {:reply, :not_changed, state}
      {:ignore, reason} ->
        {:reply, {:not_changed, reason}, state}
      other ->
        Logger.error("ring_trans: invalid return value: #{inspect other}")
        {:reply, :not_changed, state}
    end
  end

  ## persist a new ring file, set the global value and notify any listeners
  defp prune_write_notify_ring(ring) do
    state2 = prune_write_ring(ring, state)
    Rill.Ring.Event.ring_update(ring)
    state2
  end

  defp prune_write_ring(ring, state) do
    Rill.Ring.check_tainted(ring, "Error: Persisting tainted ring")
    :ok = Rill.Ring.Manager.prune_ringfiles()
    _ = do_write_ringfile(ring)
    state2 = set_ring(ring, state)
    state2
  end
end