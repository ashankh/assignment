data mongodbatlas_clusters animals-mongo {
  project_id = var.mongdbatlas_project_id
}

data mongodbatlas_cluster animals-mongo {
  for_each = toset(data.mongodbatlas_clusters.animals-mongo.results[*].name)

  project_id = var.mongdbatlas_project_id
  name       = each.value
}

  connection_strings = {
    for svc in var.service_configuration :

    mongodb+srv://svc.serviceName.:random_password.store-service-password@[svc.mongoCluster]/[svc.mongoDatabase]/[svc.mongoCollection]
  }
}


resource random_password store-service-password {
  length           = 12
  special          = true
  override_special = "_%@"
}

resource mongodbatlas_database_user store-service-user {

  # create a username for the service
  username           = "${var.environment}-${each.key}" 


  # create a password for the service 
  password           = random_password.store-service-password


  dynamic roles {
    for_each = each.value.mongoCollection[*]
    content {
      role_name       = "read"
      database_name   = each.value.marsupials-dev
      collection_name = roles.value
    }
  }
}
