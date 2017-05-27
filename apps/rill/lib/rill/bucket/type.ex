defmodule Rill.Bucket.Type do
  @moduledoc """
  
  """

  @doc """
  
  """
  def defaults(), do: custom_type_defaults()
  def defaults(:default_type) do
    default_type_defaults()
  end

  defp default_type_defaults do
    common_defaults() ++
        [dvv_enabled: false,
         allow_mult: false]
  end

  defp custom_type_defaults do
    common_defaults() ++
        [dvv_enabled: true,
         allow_mult: true]
  end

  defp common_defaults do
    [linkfun: {:modfun, :riak_kv_wm_link_walker, :mapreduce_linkfun},
     old_vclock: 86400,
     young_vclock: 20,
     big_vclock: 50,
     small_vclock: 50,
     pr: 0,
     r: :quorum,
     w: :quorum,
     pw: 0,
     dw: :quorum,
     rw: :quorum,
     basic_quorum: false,
     notfound_ok: true,
     n_val: 3,
     last_write_wins: false,
     precommit: [],
     postcommit: [],
     chash_keyfun: {:riak_core_util, :chash_std_keyfun}]
  end
end