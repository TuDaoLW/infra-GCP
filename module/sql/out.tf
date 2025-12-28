output "instance_self_link" {
  value = google_sql_database_instance.instance.self_link
}

output "instance_connection_name" {
  value = google_sql_database_instance.instance.connection_name
}

output "private_ip_address" {
  value = google_sql_database_instance.instance.private_ip_address
}

output "public_ip_address" {
  value = google_sql_database_instance.instance.public_ip_address
}