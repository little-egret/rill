defmodule Rill.Bucket do
  @moduledoc """
  
  """

  @doc """  
  Add a list of defaults to global list of defaults for new
  buckets.  
  
  If any item is in Items is already set in the
  current defaults list, the new setting is omitted, and the old
  setting is kept.  Omitting the new setting is intended
  behavior, to allow settings from config.exs to override any
  hard-coded values.

  """
  def append_bucket_defaults(items) when is_list(items) do
    Rill.Bucket.Prop.append_defaults(items)
  end
end