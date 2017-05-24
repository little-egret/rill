use Mix.Config

config :rialix_core,
  cluster_name: "default",
  platform_data_dir: "data",
  ring_creation_size: 64,
  gossip_interval: 60000,
  target_n_val: 4,
  wants_claim_fun: {:rialix_core_claim, :default_wants_claim},
  choose_claim_fun: {:rialix_core_claim, :default_choose_claim},
  vnode_inactivity_timeout: 60000,
  handoff_concurrency: 2,
  disble_http_nagle: true,
  handoff_port: 8099,
  handoff_ip: '0.0.0.0',
  dist_send_buf_size: 393216,
  dist_recv_buf_size: 786432
import_config "#{Mix.env}.exs"
## TODO exometer defults