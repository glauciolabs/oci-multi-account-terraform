# 📦 Terraform OCI Multi-Account Infrastructure

[![Terraform OCI IaC Workflow](https://github.com/glauciolabs/oci-multi-account-terraform/actions/workflows/terraform.yml/badge.svg)](https://github.com/glauciolabs/oci-multi-account-terraform/actions/workflows/terraform.yml)
[![Terraform](https://img.shields.io/badge/Terraform-~%3E%201.13.0-623CE4?style=flat&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![OCI Provider](https://img.shields.io/badge/OCI%20Provider-~%3E%207.19.0-red?style=flat&logo=oracle&logoColor=white)](https://registry.terraform.io/providers/oracle/oci/latest)
[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg?style=flat&logo=gnu&logoColor=white)](https://www.gnu.org/licenses/gpl-3.0)
[![TFLint](https://img.shields.io/badge/TFLint-validated-brightgreen?style=flat&logo=terraform&logoColor=white)](https://github.com/terraform-linters/tflint)
[![Code Quality](https://img.shields.io/badge/Code%20Quality-A-brightgreen?style=flat&logo=codeclimate&logoColor=white)](#)
[![Buy me a coffee](https://img.shields.io/badge/Buy%20me%20a%20coffee-☕-orange?style=flat&logo=buy-me-a-coffee&logoColor=white)](https://buymeacoffee.com/glauciocampos)


# Terraform OCI Multi-Account Infrastructure

This guide will help you understand and use the Terraform solution for deploying Oracle Cloud Infrastructure (OCI) resources across multiple accounts. It’s detailed and beginner-friendly to help users new to Terraform, OCI, or infrastructure automation.

---

## 🚀 What Is This Project?

This project automates the creation of cloud resources in Oracle Cloud using Terraform, an infrastructure-as-code tool. It supports managing multiple OCI accounts and environments from a single JSON configuration.

You no longer need to manually create servers, networking, or storage — Terraform does it reliably for you.

---

## 🚀 Key Features

### **🌐 Zero Trust Network Access**

- **Cloudflare WARP Connector** - Site-to-site VPN without complexity
- **Secure tunneling** - Connect private OCI networks to Cloudflare's global network
- **Mesh networking** - Bidirectional connectivity between multiple sites
- **No firewall changes** - Works without modifying existing network infrastructure


### **📱 Real-time Monitoring**

- **Telegram Integration** - Instant notifications for deployment status
- **Provisioning Updates** - Real-time feedback on instance setup
- **WARP Connection Status** - Monitor tunnel establishment
- **Error Alerting** - Immediate notification of failures


### **🏗️ Infrastructure Components**

- **ARM Ampere Compute** - Cost-effective Oracle Cloud instances
- **Shared OCFS2 Storage** - Cluster-ready shared block volumes
- **Multi-Account Support** - JSON-based configuration system
- **Flexible Networking** - Optional Network Load Balancer
- **Custom User Management** - Cloud-init with SSH key deployment


### **⚙️ DevOps \& Automation**

- **GitHub Actions CI/CD** - Automated deployment workflows
- **TFLint Integration** - Code quality validation
- **Local Development Tools** - Validation scripts
- **Smart Cleanup** - Automatic resource cleanup on failures


## 🎯 Use Cases

### **🔐 Secure Remote Access**

Connect your development team to private OCI resources through Cloudflare's Zero Trust network, eliminating traditional VPN complexity.

### **🏢 Multi-Site Connectivity**

Link multiple Oracle Cloud regions or hybrid environments with secure, encrypted tunnels managed by Cloudflare.

### **🖥️ Development Environments**

Spin up ARM-based development clusters with shared storage and instant Telegram notifications for team coordination.

### **📊 Cost-Effective Computing**

Leverage Oracle's free-tier ARM instances with enterprise-grade networking and monitoring capabilities.

## 📋 Prerequisites

- **Terraform** >= 1.13.0
- **OCI Account** with API access configured
- **Cloudflare Zero Trust** account (free tier available)
- **Telegram Bot** (optional, for notifications)
- **GitHub Actions** (for automated deployment)


## 🚀 Quick Start

### **1. Clone Repository**

```bash
git clone https://github.com/glauciolabs/oci-multi-account-terraform.git
cd oci-multi-account-terraform
```


### **2. Local Development Setup**

```bash
# Install TFLint for code quality
curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash

# Validate your code
./scripts/validate-lint.sh

# Format code
terraform fmt -recursive
```


### **3. Configure Your Environment**

Create `accounts.json` with your configuration:

```json
{
  "1": {
    "account_name": "production",
    "region": "sa-saopaulo-1",
    "tenancy_ocid": "ocid1.tenancy.oc1..aaaaaaaa...",
    "user_ocid": "ocid1.user.oc1..aaaaaaaa...",
    "fingerprint": "12:34:56:78:90:ab:cd:ef:12:34:56:78:90:ab:cd:ef",
    "private_key": "-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----",
    "compartment_ocid": "ocid1.compartment.oc1..aaaaaaaa...",
    "tf_state_bucket_name": "terraform-state-production",
    "namespace": "your-namespace",
    "prefix": "prod-cluster",
    "ssh_public_key": "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI...",
    "image_ocid": "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaath3b...",
    
    "instance_count": 2,
    "instance_shape": "VM.Standard.A1.Flex",
    "instance_memory_gb": 12,
    "instance_ocpus": 2,
    
    "vcn_cidr": "10.10.0.0/16",
    "subnet_cidr": "10.10.1.0/24",
    "public_subnet_cidr": "10.10.0.0/24",
    "assign_public_ip": false,
    
    "cf_warp_connector_secret": "eyJhIjoiYWJjZGVmZ2hpams...",
    "telegram_bot_token": "1234567890:ABCdef123gh456ijk789...",
    "telegram_chat_id": "-1001234567890",
    
    "default_user": {
      "name": "devops",
      "groups": ["wheel", "adm", "systemd-journal"],
      "sudo": "ALL=(ALL) NOPASSWD:ALL"
    },
    
    "shared_volumes_config": {
      "database_storage": {
        "display_name": "database-storage",
        "size_in_gbs": 50,
        "device": "/dev/oracleoci/oraclevdb"
      }
    }
  }
}
```


### **4. Deploy with GitHub Actions**

1. **Encode JSON**: `base64 -w 0 accounts.json`
2. **Add Secret**: Repository Settings → Secrets → `OCI_ACCOUNTS_JSON`
3. **Run Workflow**: Actions → "Terraform OCI IaC Workflow"
4. **Select Account**: Choose account number and operation (plan/apply/destroy)

## 🏗️ Architecture

### **Cloudflare WARP Integration**

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│  Your Network   │    │ Cloudflare Edge  │    │   OCI Cloud     │
│                 │    │                  │    │                 │
│  ┌─────────┐    │    │  ┌─────────────┐ │    │ ┌─────────────┐ │
│  │ WARP    │────┼────┼─→│ Zero Trust  │ │    │ │ Instance-1  │ │
│  │ Client  │    │    │  │ Network     │─┼────┼→│ + WARP      │ │
│  └─────────┘    │    │  │             │ │    │ │ Connector   │ │
│                 │    │  └─────────────┘ │    │ └─────────────┘ │
│                 │    │                  │    │ ┌─────────────┐ │
│                 │    │  📊 Dashboard   │    │ │ Instance-2  │ │
│                 │    │  📱 Policies    │    │ │ + Shared    │ │
│                 │    │  🔐 Access      │    │ │ Storage     │ │
│                 │    │                  │    │ └─────────────┘ │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                                ↕️
                        📱 Telegram Bot
                        Real-time Updates
```


### **What Happens During Deployment**

1. **🏗️ Infrastructure Creation**: OCI resources provisioned via Terraform
2. **📦 Instance Setup**: Cloud-init installs packages and configures users
3. **🔗 WARP Connection**: Each instance connects to Cloudflare Zero Trust
4. **💾 Storage Mounting**: OCFS2 shared volumes attached and configured
5. **📱 Notifications**: Telegram updates sent for each major step
6. **✅ Validation**: Health checks ensure everything is working

## 📝 Configuration Reference

### **Required OCI Fields**

| Field | Description | Example |
| :-- | :-- | :-- |
| `tenancy_ocid` | Oracle Cloud tenancy identifier | `ocid1.tenancy.oc1..aaaaaa...` |
| `user_ocid` | OCI user for API access | `ocid1.user.oc1..aaaaaa...` |
| `compartment_ocid` | Target compartment | `ocid1.compartment.oc1..aaaaaa...` |
| `fingerprint` | API key fingerprint | `12:34:56:78:90:ab:cd:ef:...` |
| `private_key` | PEM-formatted private key | `-----BEGIN PRIVATE KEY-----\n...` |
| `region` | OCI region | `sa-saopaulo-1`, `us-phoenix-1` |

### **Cloudflare Integration**

| Field | Description | Required |
| :-- | :-- | :-- |
| `cf_warp_connector_secret` | WARP Connector token from Cloudflare dashboard | ✅ |

**Getting WARP Connector Secret:**

1. Go to [Cloudflare Zero Trust Dashboard](https://one.dash.cloudflare.com/)
2. Navigate to **Networks** → **Tunnels** → **Create tunnel**
3. Select **WARP Connector** type
4. Copy the generated token

### **Telegram Notifications**

| Field | Description | Required |
| :-- | :-- | :-- |
| `telegram_bot_token` | Bot token from @BotFather | Optional |
| `telegram_chat_id` | Chat ID for notifications | Optional |

**Setting up Telegram:**

1. Message [@BotFather](https://t.me/botfather) on Telegram
2. Create new bot with `/newbot`
3. Get chat ID by messaging [@userinfobot](https://t.me/userinfobot)

### **Instance Configuration**

| Field | Type | Default | Description |
| :-- | :-- | :-- | :-- |
| `instance_count` | number | `2` | Number of instances to create |
| `instance_shape` | string | `"VM.Standard.A1.Flex"` | Instance type (ARM recommended) |
| `instance_memory_gb` | number | `12` | Memory per instance (GB) |
| `instance_ocpus` | number | `2` | CPU cores per instance |
| `assign_public_ip` | boolean | `false` | Public IP (not needed with WARP) |

### **Shared Storage (OCFS2)**

| Field | Description |
| :-- | :-- |
| `shared_volumes_config` | Map of volume configurations for clustering |
| `device` | Block device path (e.g., `/dev/oracleoci/oraclevdb`) |
| `size_in_gbs` | Volume size in GB |

## 🛠️ Development

### **Local Validation**

```bash
# Run all quality checks
./scripts/validate-lint.sh

# Manual steps
tflint --recursive
terraform fmt -check -recursive
terraform validate
```


### **Project Structure**

```
.
├── accounts/                    # Main Terraform configuration
│   ├── main.tf                 # Root module orchestration
│   ├── variables.tf            # Input variables
│   └── cloud-init.tftpl        # Instance initialization template
├── modules/                     # Reusable Terraform modules
│   ├── oci-ampere-instance/    # ARM compute instances
│   ├── oci-network/            # VCN and networking
│   ├── oci-nlb/               # Network Load Balancer
│   └── oci-shared-volumes/     # OCFS2 block storage
├── scripts/                     # Automation scripts
│   ├── deploy.sh               # Multi-account deployment
│   ├── validate-lint.sh        # Code quality validation
│   └── install-terraform.sh    # CI/CD setup
└── .github/workflows/          # GitHub Actions pipelines
```


### **Code Quality Standards**

- ✅ **TFLint validation** - Terraform best practices enforced
- ✅ **Format checking** - Consistent code formatting
- ✅ **Variable typing** - All variables properly typed and documented
- ✅ **Module validation** - Each module independently validated
- ✅ **Semantic versioning** - Release management automation


## 🔧 Troubleshooting

### **Common Issues**

#### **❌ WARP Connector fails to connect**

```bash
# Check if secret is valid
warp-cli --accept-tos status

# Verify Cloudflare Zero Trust configuration
# Ensure tunnel is active in dashboard
```


#### **❌ Telegram notifications not working**

```bash
# Test bot token manually
curl -X GET "https://api.telegram.org/bot<TOKEN>/getMe"

# Verify chat ID
curl -X POST "https://api.telegram.org/bot<TOKEN>/sendMessage" \
  -d "chat_id=<CHAT_ID>&text=Test message"
```


#### **❌ OCFS2 volumes not mounting**

```bash
# Check volume attachment
sudo iscsiadm -m session

# Verify OCFS2 installation
rpm -qa | grep ocfs2-tools
```


### **Logs and Debugging**

```bash
# Cloud-init logs
sudo tail -f /var/log/cloud-init-output.log

# WARP connector status
warp-cli --accept-tos status

# System journal
journalctl -u cloud-init -f
```


## 💰 Cost Estimation

| Configuration | Monthly Cost* | Components |
| :-- | :-- | :-- |
| **Single Dev** | ~\$0 | 1x A1.Flex (Always Free) |
| **Small Team** | ~\$25 | 2x A1.Flex + 100GB storage |
| **Production** | ~\$60 | 3x A1.Flex + 200GB + NLB |

*Estimates for Oracle Cloud São Paulo region. Always Free tier includes 4 OCPU, 24GB RAM, 200GB storage.

## 🤝 Contributing

1. **Fork** the repository
2. **Create** feature branch (`git checkout -b feature/awesome-feature`)
3. **Validate** code (`./scripts/validate-lint.sh`)
4. **Commit** with [Conventional Commits](https://conventionalcommits.org/)
5. **Open** Pull Request

### **Development Standards**

- All Terraform code must pass TFLint validation
- Variables must be typed and documented
- Modules must have proper outputs for integration
- Cloud-init templates must be tested


## ☕ Support This Project

If this project helped you build secure, cost-effective cloud infrastructure, consider supporting its development:

<a href="https://buymeacoffee.com/glauciocampos" target="_blank">
  <img src="https://cdn.buymeacoffee.com/buttons/v2/default-orange.png" alt="Buy Me A Coffee" height="50" width="180">
</a>


**Why support?**

- ✅ **Continued development** of new cloud integrations
- ✅ **Bug fixes** and security updates
- ✅ **Documentation** improvements and examples
- ✅ **Community support** in issues and discussions

Your support keeps this project **free** and **actively maintained**!

## 📄 License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.

### **GPL v3 Key Points:**

- ✅ **Freedom to use, study, modify** the software
- ✅ **Copyleft protection** - derivatives must also be GPL v3
- ✅ **Source code availability** - modifications must include source
- ✅ **Community benefit** - ensures improvements remain open source


## 🆘 Support

- **🐛 Issues**: [Report bugs or request features](https://github.com/glauciolabs/oci-multi-account-terraform/issues)
- **💬 Discussions**: [Community discussions](https://github.com/glauciolabs/oci-multi-account-terraform/discussions)
- **📚 Wiki**: [Documentation and guides](https://github.com/glauciolabs/oci-multi-account-terraform/wiki)

***


**💡 Found this useful?** 

[![Buy me a coffee](https://img.shields.io/badge/Buy%20me%20a%20coffee-☕-orange?style=for-the-badge&logo=buy-me-a-coffee&logoColor=white)](https://buymeacoffee.com/glauciocampos)