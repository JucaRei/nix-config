path "secret/excalibur/gitlab-runner/*" {
  capabilities = ["create", "read", "list"]
}

path "secret/data/excalibur/gitlab-runner/*" {
  capabilities = ["create", "read", "list"]
}

path "secret/excalibur/data/gitlab-runner" {
  capabilities = ["create", "read", "list"]
}

path "auth/approle/login" {
  capabilities = ["create", "read"]
}
