resource "kubernetes_secret" "db_configs" {
  metadata {
    name      = var.secrets.name
    namespace = var.namespace
  }

  data = var.secrets.values
}

resource "random_id" "secret" {
  byte_length = 32
}

resource "random_id" "code_execute_key" {
  byte_length = 32
}

resource "random_id" "plugin_server_key" {
  byte_length = 32
}

resource "random_id" "api_inner_api_key" {
  byte_length = 32
}

resource "kubernetes_secret" "dify_secret" {
  metadata {
    name      = "dify-credentials"
    namespace = var.namespace
  }

  data = {
    "secret_key"       = format("'%s'", random_id.secret.b64_std)
    "code_execute_key" = format("'%s'", random_id.code_execute_key.b64_std)
    "plugin_server_key" = format("'%s'", random_id.plugin_server_key.b64_std)
    "api_inner_api_key" = format("'%s'", random_id.api_inner_api_key.b64_std)
  }
}
