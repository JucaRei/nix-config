path "secret/excalibur" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "secret/data/excalibur/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "secret/excalibur/data/*" {
  capabilities = ["read", "list"]
}

# TODO: Move all vpn policies to a seperate policy
# Allow reading from the PKI secrets engine to issue server certificates
path "excalibur-pki/issue/vpn-server-role" {
  capabilities = ["create", "read", "update"]
}

# Allow reading from the PKI secrets engine to issue client certificates
path "excalibur-pki/issue/vpn-client-role" {
  capabilities = ["create", "read", "update"]
}

path "excalibur-pki/issue/vpn-server-role" {
  capabilities = ["create", "read", "update"]
}

path "excalibur-pki/issue/*" {
  capabilities = ["create", "read", "update"]
}

# Allow reading the CA certificate
path "excalibur-pki/ca" {
  capabilities = ["read"]
}

# Allow reading the CRL configuration
path "excalibur-pki/crl" {
  capabilities = ["read"]
}

path "excalibur-pki/roles/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "auth/approle/login" {
  capabilities = ["create", "read"]
}
