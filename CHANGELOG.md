# Changelog

## [1.0.0] - 2026-10-03

### Added
- Modules: project-services, network, kms, gke, iam, artifact-registry, budget, landing-zone.
- `envs/dev` and `envs/prod` roots with a GCS backend, and `bootstrap/` for the state bucket.
- GitHub Workload Identity Federation with separate read-only plan and deploy accounts.
- 25 `terraform test` cases with a mocked provider; tflint, checkov and terraform-docs in CI.
- Plan-on-PR and apply-on-merge workflows using keyless authentication.
