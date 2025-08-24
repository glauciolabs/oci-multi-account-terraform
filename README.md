[![Terraform OCI IaC Workflow](https://github.com/glauciolabs/oci-iac-ops/actions/workflows/terraform.yml/badge.svg)](https://github.com/glauciolabs/oci-iac-ops/actions/workflows/terraform.yml)


# Terraform OCI Multi-Account Infrastructure

This guide will help you understand and use the Terraform solution for deploying Oracle Cloud Infrastructure (OCI) resources across multiple accounts. It’s detailed and beginner-friendly to help users new to Terraform, OCI, or infrastructure automation.

---

## 🚀 What Is This Project?

This project automates the creation of cloud resources in Oracle Cloud using Terraform, an infrastructure-as-code tool. It supports managing multiple OCI accounts and environments from a single JSON configuration.

You no longer need to manually create servers, networking, or storage — Terraform does it reliably for you.

---

## ⚙️ How It Works

- Define your accounts and configuration in a single JSON file.
- Run a deploy script (locally or in GitHub Actions).
- Terraform reads this config and provisions:
  - Virtual Cloud Networks (VCNs) and subnets,
  - Compute instances,
  - Shared storage volumes,
  - Optional network load balancers,
- On first boot, cloud-init configures your instances (users, packages, Cloudflare WARP).
- Deployment progress notifications are sent to Telegram (optional).

---

## 📁 Project Structure

```

.
├── accounts
│   ├── cloud-init.tftpl        \# Cloud-init template for instance bootstrapping
│   ├── main.tf                 \# Root Terraform configuration orchestrating the modules
│   └── variables.tf            \# Root-level variable declarations
├── LICENSE                    \# License file
├── modules                    \# Reusable Terraform modules
│   ├── oci-ampere-instance
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── oci-network
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── oci-nlb
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   └── oci-shared-volumes
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
├── README.md                  \# This documentation file
└── scripts
├── deploy.sh              \# Script to run Terraform deploy per account
└── install-terraform.sh   \# Script to silently install Terraform v1.13.0

```

---

## 📝 Preparing Your Multi-Account Configuration JSON (`accounts.json`)

Below is an example JSON file configuring **two** OCI accounts with realistic fields filled in. Adjust values accordingly.

```json
{
  "1": {
    "account_name": "production",
    "region": "sa-saopaulo-1",
    "tenancy_ocid": "ocid1.tenancy.oc1..prodtenancyocid",
    "user_ocid": "ocid1.user.oc1..produserocid",
    "fingerprint": "aa:bb:cc:dd:ee:ff:11:22:33:44:55:66:77:88:99:00",
    "private_key": "-----BEGIN PRIVATE KEY-----\nYOUR_PROD_PRIVATE_KEY_CONTENT\n-----END PRIVATE KEY-----",
    "compartment_ocid": "ocid1.compartment.oc1..prodcompartmentocid",
    "tf_state_bucket_name": "prod-terraform-state-bucket",
    "namespace": "prod_object_storage_namespace",
    "prefix": "prod-cluster",
    "ssh_public_key": "ssh-ed25519 AAAA...your_production_ssh_key...",
    "image_ocid": "ocid1.image.oc1.sa-saopaulo-1.prodimageocid",
    "instance_count": 3,
    "instance_shape": "VM.Standard.A1.Flex",
    "instance_memory_gb": 24,
    "instance_ocpus": 4,
    "ad_number": 1,
    "vcn_cidr": "10.10.0.0/16",
    "subnet_cidr": "10.10.1.0/24",
    "public_subnet_cidr": "10.10.0.0/24",
    "assign_public_ip": false,
    "create_nlb": true,
    "nlb_listener_port": 443,
    "nlb_health_check_port": 80,
    "cf_warp_connector_secret": "prod_cloudflare_warp_secret",
    "telegram_bot_token": "prod_telegram_bot_token",
    "telegram_chat_id": "prod_telegram_chat_id",
    "default_user": {
      "name": "produser",
      "groups": [
        "wheel",
        "adm",
        "systemd-journal"
      ],
      "sudo": "ALL=(ALL) NOPASSWD:ALL"
    },
    "block_volumes": [
      {
        "display_name": "prod-database-storage",
        "size_in_gbs": 50,
        "device": "/dev/oracleoci/oraclevdb"
      },
      {
        "display_name": "prod-file-storage",
        "size_in_gbs": 100,
        "device": "/dev/oracleoci/oraclevdc"
      }
    ]
  },
  "2": {
    "account_name": "development",
    "region": "sa-saopaulo-1",
    "tenancy_ocid": "ocid1.tenancy.oc1..devtenancyocid",
    "user_ocid": "ocid1.user.oc1..devuserocid",
    "fingerprint": "11:22:33:44:55:66:77:88:99:00:aa:bb:cc:dd:ee:ff",
    "private_key": "-----BEGIN PRIVATE KEY-----\nYOUR_DEV_PRIVATE_KEY_CONTENT\n-----END PRIVATE KEY-----",
    "compartment_ocid": "ocid1.compartment.oc1..devcompartmentocid",
    "tf_state_bucket_name": "dev-terraform-state-bucket",
    "namespace": "dev_object_storage_namespace",
    "prefix": "dev-cluster",
    "ssh_public_key": "ssh-ed25519 AAAA...your_development_ssh_key...",
    "image_ocid": "ocid1.image.oc1.sa-saopaulo-1.devimageocid",
    "instance_count": 1,
    "instance_shape": "VM.Standard.A1.Flex",
    "instance_memory_gb": 12,
    "instance_ocpus": 2,
    "ad_number": 1,
    "vcn_cidr": "10.20.0.0/16",
    "subnet_cidr": "10.20.1.0/24",
    "public_subnet_cidr": "10.20.0.0/24",
    "assign_public_ip": true,
    "create_nlb": false,
    "nlb_listener_port": 80,
    "nlb_health_check_port": 22,
    "cf_warp_connector_secret": "dev_cloudflare_warp_secret",
    "telegram_bot_token": "dev_telegram_bot_token",
    "telegram_chat_id": "dev_telegram_chat_id",
    "default_user": {
      "name": "devuser",
      "groups": [
        "wheel",
        "adm",
        "systemd-journal"
      ],
      "sudo": "ALL=(ALL) NOPASSWD:ALL"
    },
    "block_volumes": [
      {
        "display_name": "dev-data-storage",
        "size_in_gbs": 25,
        "device": "/dev/oracleoci/oraclevdb"
      }
    ]
  }
}

```

---

## 🔐 Preparing Secrets and Keys

Terraform needs your OCI private key and the above JSON as inputs, but they must be safely handled.

### 1. Prepare Your Private Key

Ensure your private key is PEM formatted and properly escaped for JSON.  
If your key is in a file `oci_api_key.pem`, convert it to a JSON-safe escaped string:

```

awk '{printf "%s\\n", \$0}' oci_api_key.pem

```

This produces all lines joined with `\n` for JSON inclusion.

Example:

```

-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAA...

```

Place this string as the value for `"private_key"` in your `accounts.json`.

---

### 2. Generating the GitHub Secret from the JSON

Once your `accounts.json` file is ready and filled:

- Encode the entire JSON file to a single-line Base64 string:

```

cat accounts.json | base64 -w 0

```

- Copy the output string.

- In GitHub repository:

  - Navigate to **Settings** → **Secrets and variables** → **Actions**.

  - Create a new repository secret named `OCI_ACCOUNTS_JSON`.

  - Paste the Base64 string as its value.

This securely makes your multi-account configuration available for GitHub Actions workflows.

---

## 🚀 Deploying Infrastructure

### Locally via Script

1. Install Terraform if needed:

```

bash scripts/install-terraform.sh

```

2. Run deploy script:

```

bash scripts/deploy.sh accounts.json 1 apply ./accounts

```

Where:

- `accounts.json` is your config file,
- `1` is the account ID from the JSON (production in example),
- `apply` tells Terraform to create/update resources,
- `./accounts` is the Terraform root directory.

To destroy:

```

bash scripts/deploy.sh accounts.json 1 destroy ./accounts

```

### Using GitHub Actions

- Trigger the workflow manually or on commits.
- Choose account and operation (`plan`, `apply`, `destroy`).
- The `OCI_ACCOUNTS_JSON` secret provides config securely.

---

## Summary

This guide and configuration allow you to manage multiple OCI environments consistently and securely with Terraform automation and CI/CD integration. Using the provided JSON template and scripts, you can scale your infrastructure management with confidence.

If you have questions or need further help, just ask!
```

feat: Add NLB, Cloud-Init, and advanced networking
