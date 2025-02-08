# terraform-oci-arm-tailscale

This repository provides Terraform configuration for deploying a secure Oracle Cloud ARM-based Ubuntu instance using the Always-Free tier. The instance is firewalled and integrated with [Tailscale](https://tailscale.com) for private networking and includes [Docker](https://www.docker.com) pre-installed.

## Features

- **Free Oracle Cloud ARM VM**:
  - 4 CPUs, 24 GB RAM, 200 GB storage.
  - OS Image: Ubuntu 24.04.
- **Integrated with Tailscale** for private networking.
- **Pre-configured with Docker**.
- **Hardened Security**:
  - Blocks all public internet traffic except Tailscale NAT traversal protocols and HTTP/HTTPS ports.
  - Managed firewall rules via Oracle Cloud’s Virtual Cloud Network (VCN).
- **Bypasses Oracle Idle Compute Instance Restrictions**:
  - Ensures continuous activity to prevent instances from being flagged as idle and terminated.
- **Pre-installed Git** for version control operations.
- **Pre-configured Zsh** as the default shell for enhanced command-line experience.

> **Note**: Due to Oracle's account restrictions, NAT gateways (though free) are unavailable for accounts without a payment method. Thus, the VM must have a public IP.

## Prerequisites

1. **Oracle Cloud Account** (Always-Free tier).
2. **Tailscale Account** for private networking.
3. **GitHub Account** with SSH keys configured.

You can optionally install Terraform locally, but Oracle Cloud’s UI supports deploying this configuration directly.

## Deployment Steps

1. **Clone the Repository**
   ```bash
   git clone git@github.com:nhutdm/terraform-oci-arm-tailscale
   cd terraform-oci-arm-tailscale
   ```

2. **Create a Secrets File**
   ```bash
   cp secret.auto.tfvars.example secret.auto.tfvars
   ```

3. **Update Secret Values**
   - Set your `github_user` in `secret.auto.tfvars`.
   - Create a new Compartment in Oracle Cloud: [Create Compartment](https://cloud.oracle.com/identity/compartments).
     Copy the Compartment OCID and update the secrets file.
   - Generate a Tailscale Auth Key: [Generate Key](https://login.tailscale.com/admin/settings/authkeys).
     Copy the key and update the secrets file.

4. **Deploy the Stack**
   - Navigate to [Oracle Cloud Stacks](https://cloud.oracle.com/resourcemanager/stacks).
   - Upload the repository folder or a zipped version.

5. **Apply the Stack**
   Complete the setup form and apply the stack. Once successfully deployed, you can SSH into the VM using Tailscale.

## Connecting via SSH

After deployment, connect to your VM:
```bash
ssh oci-arm
```

> If your local username doesn’t match your GitHub username, use:
```bash
ssh ${GITHUB_USER}@oci-arm
```

## Using Docker Remotely

You can manage ARM64 containers on your VM remotely:
```bash
GITHUB_USER=octocat

docker context create oracle-arm --docker "host=ssh://${GITHUB_USER}@oci-arm"

DOCKER_CONTEXT=oci-arm docker run --name nginx -d --rm -p 80:80 nginx

curl oci-arm

DOCKER_CONTEXT=oci-arm docker stop nginx
```

## Debugging

If you’re unable to SSH into the VM:
1. Regenerate your Tailscale key and update the stack.
2. Temporarily allow SSH (TCP/22) via the VM's public IP in the VCN Security List to debug.
