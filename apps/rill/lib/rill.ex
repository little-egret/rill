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
end
