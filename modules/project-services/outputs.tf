output "services" {
  description = "Enabled APIs, for use in depends_on."
  value       = [for s in google_project_service.this : s.service]
}
