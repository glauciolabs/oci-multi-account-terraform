# CHANGELOG

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

### Legal
- **License**: This project is distributed under GNU General Public License v3.0
- **Copyleft Protection**: Ensures all derivatives remain open source
- **Community Collaboration**: GPL v3 promotes collective development

## [1.1.0] - 2025-09-19

### Added
- **TFLint Integration**: Comprehensive Terraform linting with `.tflint.hcl` configuration
- **GitHub Actions CI/CD**: Multi-job workflow with dependency management
- **Code Quality Validation**: Automated format checking and syntax validation

## [1.0.1] - 2025-08-24

### Fixed
- Enforced Terraform v1.13.0 in `install-terraform.sh`
- Updated GitHub Actions workflow to use the script correctly
- Added workflow badge to `README.md`

---

## [1.0.0] - 2025-08-23

### Highlights
- Modular Terraform setup: network, compute, volumes, NLB
- Multi-account orchestration via `accounts.json`
- Automated instance bootstrap with cloud-init
- Optional integrations: Telegram & Cloudflare WARP
- Unified deploy pipeline with `deploy.sh`
- Full onboarding guide in `README.md`
- Added `CHANGELOG.md`
- Added `VERSION`

---

## [0.1.0] - 2025-08-14

### Highlights
- Monolithic Terraform structure for OCI
- Remote backend using Object Storage
- VCN and public subnet with Internet Gateway
- Ampere A1 Flex instances with SSH key injection
- Basic security list with SSH access (port 22)

---
