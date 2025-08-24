# 📦 CHANGELOG

## v1.0.1 — Fix Terraform install version in CI/CD 🔧

### Fixed
- Enforced Terraform v1.13.0 in `install-terraform.sh`
- Updated GitHub Actions workflow to use the script correctly
- Added workflow badge to `README.md`

---

## v1.0.0 — Modular & Multi-Account OCI Infrastructure 🚀

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

## v0.1.0 — Initial OCI Terraform Setup 🧱

### Highlights
- Monolithic Terraform structure for OCI
- Remote backend using Object Storage
- VCN and public subnet with Internet Gateway
- Ampere A1 Flex instances with SSH key injection
- Basic security list with SSH access (port 22)

---

