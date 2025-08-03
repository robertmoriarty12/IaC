# Azure Infrastructure as Code (IaC) - Modular Enterprise Approach

This repository contains a modular, enterprise-grade Infrastructure as Code solution for Azure using Bicep templates. The structure is designed for scalability, reusability, and maintainability.

## 🏗️ Architecture Overview

```
IaC/
├── infra-modules/          # Reusable infrastructure modules
│   ├── compute/
│   │   └── vm.bicep        # Virtual Machine module
│   └── network/
│       ├── vnet.bicep      # Virtual Network module
│       ├── nsg.bicep       # Network Security Group module
│       ├── nic.bicep       # Network Interface module
│       └── publicip.bicep  # Public IP module
├── projects/               # Project-specific deployments
│   └── hybrid-ad-lab/      # Hybrid AD Lab project
│       ├── main.bicep      # Main deployment template
│       └── main.parameters.json
└── .github/workflows/      # GitHub Actions workflows
    └── deploy.yml
```

## 🎯 Current Project: Hybrid AD Lab

The `hybrid-ad-lab` project deploys a complete lab environment for testing Microsoft Defender for Identity and Active Directory Domain Services:

### Resources Deployed:
- **Virtual Network**: 10.0.0.0/16 with default subnet (10.0.0.0/24)
- **Network Security Group**: Allows RDP access from Internet
- **Domain Controller VM**: Windows Server 2019 (Standard_D2s_v3)
- **Defender for Identity VM**: Windows Server 2019 (Standard_D4s_v3)
- **Public IPs**: Both VMs have public IPs for remote access

## 🚀 Deployment

### Prerequisites:
1. Azure subscription with appropriate permissions
2. GitHub repository with Azure credentials configured
3. Bicep CLI installed (handled by GitHub Actions)

### GitHub Actions Deployment:
1. Go to your GitHub repository
2. Navigate to Actions → "Deploy Azure IaC Project"
3. Click "Run workflow"
4. Configure parameters:
   - **Project**: `hybrid-ad-lab`
   - **Environment**: `dev` (or `test`/`prod`)
   - **Location**: `eastus` (or your preferred region)
5. Click "Run workflow"

### Manual Deployment:
```bash
# Login to Azure
az login

# Create resource group
az group create --name hybrid-ad-lab-dev-rg --location eastus

# Deploy the template
az deployment group create \
  --resource-group hybrid-ad-lab-dev-rg \
  --template-file projects/hybrid-ad-lab/main.bicep \
  --parameters @projects/hybrid-ad-lab/main.parameters.json
```

## 🔧 Module Structure

### Network Modules (`infra-modules/network/`)

#### `vnet.bicep`
- **Purpose**: Deploy Virtual Networks with configurable subnets
- **Parameters**: name, location, addressPrefixes, subnets, tags
- **Outputs**: vnetId, vnetName, subnetIds, subnetNames

#### `nsg.bicep`
- **Purpose**: Deploy Network Security Groups with configurable rules
- **Parameters**: name, location, securityRules, tags
- **Outputs**: nsgId, nsgName

#### `publicip.bicep`
- **Purpose**: Deploy Public IP addresses for VM accessibility
- **Parameters**: name, location, allocationMethod, sku, tags
- **Outputs**: publicIpId, publicIpName, publicIpAddress

#### `nic.bicep`
- **Purpose**: Deploy Network Interfaces with optional public IP
- **Parameters**: name, location, subnetId, nsgId, publicIpId, tags
- **Outputs**: nicId, nicName

### Compute Modules (`infra-modules/compute/`)

#### `vm.bicep`
- **Purpose**: Deploy Virtual Machines with configurable specs
- **Parameters**: name, location, adminUsername, adminPassword, nicId, vmSize, imagePublisher, imageOffer, imageSku, imageVersion, tags
- **Outputs**: vmId

## 🏷️ Tagging Strategy

All resources are tagged with:
- **Project**: Project identifier
- **Environment**: dev/test/prod
- **Owner**: GitHubActions
- **Purpose**: HybridADLab
- **Role**: Specific role (DomainController, DefenderForIdentity)

## 🔒 Security Considerations

### Current Configuration:
- RDP access allowed from Internet (for lab purposes)
- Standard SKU Public IPs
- Basic NSG rules

### Production Recommendations:
1. **Restrict RDP access** to specific IP ranges
2. **Use Azure Bastion** for secure VM access
3. **Implement Azure Firewall** for advanced network security
4. **Enable Azure Security Center** monitoring
5. **Use Key Vault** for credential management

## 📝 Adding New Projects

1. Create a new folder under `projects/`
2. Create `main.bicep` using existing modules
3. Create `main.parameters.json` with project-specific values
4. Update the GitHub Actions workflow if needed

### Example Project Structure:
```
projects/
└── my-new-project/
    ├── main.bicep
    └── main.parameters.json
```

## 🐛 Troubleshooting

### Common Issues:

1. **Module not found errors**:
   - Ensure relative paths in module references are correct
   - Check that all referenced modules exist

2. **Parameter validation errors**:
   - Verify all required parameters are provided
   - Check parameter types and constraints

3. **Resource naming conflicts**:
   - Ensure unique resource names across deployments
   - Use the resourcePrefix variable consistently

4. **Permission errors**:
   - Verify Azure credentials have appropriate permissions
   - Check subscription and resource group access

### Debug Commands:
```bash
# Validate Bicep template
az bicep build --file projects/hybrid-ad-lab/main.bicep

# What-if analysis
az deployment group what-if \
  --resource-group hybrid-ad-lab-dev-rg \
  --template-file projects/hybrid-ad-lab/main.bicep \
  --parameters @projects/hybrid-ad-lab/main.parameters.json

# Check deployment status
az deployment group show \
  --resource-group hybrid-ad-lab-dev-rg \
  --name <deployment-name>
```

## 📞 Support

For issues or questions:
1. Check the troubleshooting section above
2. Review Azure Bicep documentation
3. Check GitHub Actions logs for detailed error messages

## 🔄 Version History

- **v1.0**: Initial modular structure
- **v1.1**: Added public IP support and improved security
- **v1.2**: Enhanced GitHub Actions workflow with better error handling 