defmodule Rill.Ring.Manager do
  @moduledoc """
  
  """
  require Logger

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
end