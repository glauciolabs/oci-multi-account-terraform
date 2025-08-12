# Terraform OCI Multi-Account Infrastructure

A comprehensive Terraform solution for deploying Oracle Cloud Infrastructure (OCI) resources across multiple accounts using GitHub Actions automation, modular architecture, and native OCI backend state management.

## 🏗️ Architecture Overview

This solution provides:
- **Multi-Account Support**: Deploy infrastructure to different OCI accounts using JSON configuration
- **Modular Design**: Reusable Terraform modules for networking and compute resources
- **GitHub Actions Integration**: Automated deployment workflows with secure secret management
- **Native OCI Backend**: Remote state storage using OCI Object Storage
- **Ampere Instance Deployment**: ARM-based compute instances with flexible configurations

## 📁 Project Structure


## 🚀 Features

### **Infrastructure Components**
- **Virtual Cloud Network (VCN)** with custom CIDR blocks
- **Public subnet** with internet gateway
- **Security groups** with SSH, HTTP, and HTTPS access
- **Route tables** for internet connectivity
- **ARM-based Ampere instances** (2x VM.Standard.A1.Flex)
- **Flexible resource configuration** via JSON parameters

### **Automation & CI/CD**
- **GitHub Actions workflow** for automated deployments
- **Multi-account management** through JSON configuration
- **Secure credential handling** with Base64 encoded secrets
- **Remote state management** using OCI Object Storage
- **Plan, Apply, and Destroy operations** through web interface

## 🔧 Prerequisites

- Oracle Cloud Infrastructure (OCI) account
- OCI API keys and authentication setup
- GitHub repository with Actions enabled
- Local environment with `jq` and `curl` installed

## ⚙️ Configuration

### **1. Account Configuration JSON**

Create a JSON file with your account details:

```json
{
"1": {
"account_name": "production",
"availability_domain": "region-AD-1",
"compartment_ocid": "ocid1.compartment.oc1..your-compartment-id",
"fingerprint": "aa:bb:cc:dd:ee:ff:00:11:22:33:44:55:66:77:88:99",
"image_ocid": "ocid1.image.oc1.region.your-image-id",
"namespace": "your-tenancy-namespace",
"prefix": "prod",
"region": "us-phoenix-1",
"ssh_public_key": "ssh-rsa AAAAB3NzaC1yc2E...",
"subnet_cidr": "10.0.1.0/24",
"tenancy_ocid": "ocid1.tenancy.oc1..your-tenancy-id",
"tf_state_bucket_name": "terraform-state",
"user_ocid": "ocid1.user.oc1..your-user-id",
"vcn_cidr": "10.0.0.0/16",
"private_key": "-----BEGIN PRIVATE KEY-----\n..."
}
}
```

### **2. GitHub Secrets Setup**

1. Add your private key to the JSON configuration:

```bash
jq --arg private_key "$(cat ~/.oci/your_api_key.pem)"
'.["1"].private_key = $private_key'
config.json > updated_config.json
```

2. Encode the JSON as Base64:

```bash
cat updated_config.json | base64 -w 0 > github_secret.txt
```



3. Add to GitHub Repository:
   - Go to **Settings → Secrets and variables → Actions**
   - Create **New repository secret**
   - Name: `OCI_ACCOUNTS_JSON`
   - Value: Contents of `github_secret.txt`

## 🚀 Usage

### **GitHub Actions Deployment**

1. Navigate to **Actions** tab in your GitHub repository
2. Select **Terraform OCI Multi-Account** workflow
3. Click **Run workflow**
4. Configure parameters:
   - **Account Number**: Select account (1, 2, 3, etc.)
   - **Operation**: Choose `plan`, `apply`, or `destroy`
5. Monitor execution in the Actions log

### **Local Development**

1. **Install Terraform** (if not installed):

```bash
sudo bash scripts/install-terraform.sh
```

2. **Run Terraform operations**:

```bash
#Navigate to project directory
cd /path/to/project

#Execute plan operation
bash scripts/run.sh config.json 1 plan $(pwd)/accounts

#Execute apply operation
bash scripts/run.sh config.json 1 apply $(pwd)/accounts
```

## 🔐 Security Features

- **Private key encryption**: Keys are stored encrypted in GitHub Secrets
- **Temporary file cleanup**: Sensitive files are automatically removed after execution
- **Secure authentication**: Uses OCI API key authentication
- **State encryption**: Remote state stored securely in OCI Object Storage
- **Access control**: Configurable security groups and network ACLs

## 🏛️ Infrastructure Details

### **Network Configuration**
- **VCN**: Virtual Cloud Network with custom CIDR
- **Public Subnet**: Internet-accessible subnet for instances
- **Internet Gateway**: Provides internet access
- **Route Tables**: Routes traffic to/from internet
- **Security Lists**: Allows SSH (22), HTTP (80), HTTPS (443)

### **Compute Configuration**
- **Shape**: VM.Standard.A1.Flex (ARM-based Ampere)
- **Memory**: 12 GB RAM per instance
- **vCPUs**: 2 OCPUs per instance
- **Count**: 2 instances by default
- **OS**: Configurable via image OCID
- **Access**: SSH key-based authentication

## 🔄 Backend State Management

The solution uses OCI's native Terraform backend for remote state storage:

- **State Location**: OCI Object Storage bucket
- **Encryption**: Server-side encryption enabled
- **Locking**: Prevents concurrent modifications
- **Versioning**: Maintains state history
- **Access Control**: Secure API-based authentication

## 🛠️ Customization

### **Adding New Accounts**
Add additional account configurations to your JSON file with unique keys:


{
"1": { /* account 1 config / },
"2": { / account 2 config / },
"3": { / account 3 config */ }
}


### **Modifying Instance Configuration**
Edit `modules/oci-ampere-instance/main.tf`:
- Change instance count
- Modify CPU/memory allocation
- Update security configurations
- Add additional storage

### **Network Customization**
Edit `modules/oci-network/main.tf`:
- Modify CIDR blocks
- Add additional subnets
- Configure custom security rules
- Add load balancers or NAT gateways

## 📊 Monitoring & Troubleshooting

### **GitHub Actions Logs**
Monitor deployment progress through GitHub Actions interface:
- Real-time execution logs
- Resource creation status
- Error debugging information

### **Common Issues**
1. **Provider Configuration Errors**: Ensure `required_providers` block is removed from `main.tf`
2. **Authentication Failures**: Verify API key format and GitHub secret configuration
3. **Resource Limits**: Check OCI service limits and quotas
4. **Network Connectivity**: Verify VCN and subnet configurations

## 📋 Requirements

- **Terraform**: >= 1.12.0 (for native OCI backend support)
- **OCI Provider**: Latest version (automatically installed)
- **System Dependencies**: `curl`, `unzip`, `jq`, `base64`
- **OCI Permissions**: Full access to Compute, Networking, and Object Storage services

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔗 Additional Resources

- [Oracle Cloud Infrastructure Documentation](https://docs.oracle.com/en-us/iaas/)
- [Terraform OCI Provider Documentation](https://registry.terraform.io/providers/oracle/oci/latest/docs)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [OCI Ampere Instance Documentation](https://docs.oracle.com/en-us/iaas/Content/Compute/References/arm-based-instances.htm)

---

**Note**: This solution is designed for production use with proper security practices. Always review and test configurations in development environments before applying to production resources.