disable_mlock = true

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = true
}

storage "raft" {
  path    = "/vault/data"
  node_id = "node1"
}

api_addr = "http://staynest-hashicorp-vault:8200"
cluster_addr = "http://staynest-hashicorp-vault:8201"

ui = true