defmodule ClusterInfo do
  @moduledoc """
  Documentation for ClusterInfo.
  """

  @doc """
  "Register" an application with the cluster_info app.

  "Registration" is a misnomer: we're really interested only in
  having the code server load the callback module, and it's that
  side-effect with the code server that we rely on later.

  """
  @spec register_app(atom) :: :ok | nil
  def register_app(callback_mod) do
    apply(callback_mod, :cluster_info_init, [])
  catch
    _, _ ->
      nil
  end
end
