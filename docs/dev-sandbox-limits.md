# Dev Sandbox Limits

The dev environment runs on a KodeKloud Azure sandbox. Each session is
ephemeral (~3 hours), gives you **one predefined resource group**, and rotates
the subscription ID on every re-roll. Provider registration is disabled.

When adding new units to the dev stack, check the allowed SKUs and quotas
below. Values marked here are the **only** ones the sandbox policy permits.

## General Constraints

| Constraint | Detail |
|---|---|
| Resource groups | One predefined RG; cannot create new ones |
| Region | Locked to the RG's region |
| Subscription | Changes on every re-roll |
| Provider registration | Not allowed (`resource_provider_registrations = "none"`) |

## Allowed Services & SKUs

### Storage Accounts

- `Standard_LRS`, `Standard_RAGRS`

### Virtual Machines

- `Standard_D2s_v3`, `Standard_B2s`, `Standard_B1s`, `Standard_DS1_v2`
- Max disk size: 128 GB; no premium disks

### Virtual Machine Scale Sets

- `Standard_D2s_v3`, `Standard_K8S2_v1`, `Standard_K8S_v1`, `Standard_B2s`,
  `Standard_B1s`, `Standard_DS1_v2`, `Standard_B4ms`
- Max 3 instances

### Azure Kubernetes Service

- Agent pool VM size: `Standard_D2s_v3`
- Max 1 node pool, 2 nodes per pool

### Container Registry

- `Basic`, `Standard`

### Container Instances

- SKU: `Standard`
- CPU: 0.25 - 2 cores; Memory: 0.5 - 4 GB

### Container Apps / Managed Environments

- Workload profile: `Consumption`
- Environment name must be `container-app-env`
- Scale: min 0-1 replicas, max 0-2 replicas

### App Service

- `Free (F1)`, `Basic (B1)`

### SQL Databases

- `Basic`, `S0`-`S4`, `DW100`, `DW200`
- Backup redundancy: `Local`

### PostgreSQL (Flexible Server)

- Tier: `Burstable`; SKUs: `Standard_B1ms`, `Standard_B2s`
- Backup: periodic, non-geo-redundant

### Cosmos DB

- Capacity mode: `Provisioned` only
- Backup: `Periodic` with local redundancy

### Key Vault

- SKU: `Standard`

### Service Bus

- SKU: `Basic`

### Event Hub

- `Basic`, `Standard`

### Event Grid

- Topics: kind `Azure`, SKU `Basic`, data residency `WithinRegion`
- Namespaces: `Standard`
- Domains: `Basic`, data residency `WithinRegion`

### API Management

- SKU: `Basic`

### Log Analytics Workspace

- SKU: `PerGB2018` only
- Retention: max 30 days

### Networking

| Resource | Constraint |
|---|---|
| Load Balancer | Max 3 per session |
| NAT Gateway | Max 5 |
| Virtual Network Gateway | `VpnGw1`, Generation1 |
| Azure Firewall | Tier: `Basic` |
| Application Gateway | Tier: `Basic` |
| Azure Bastion | SKU: `Basic` |
| Route Server | Max 1 per session |
| Traffic Manager | View disabled; max 5 endpoints; methods: Weighted, Priority, Subnet |
| Virtual WAN | Type: `Basic` |
| Network Watcher | RG is restricted; dependent resources still work |

### CDN / Front Door

- Azure Front Door: `Standard` tier; max 5 routing rules
- Azure CDN: `Standard from Microsoft (Classic)`
- Front Door Classic: allowed

### IoT

- IoT Hub: `S1`, `B1`; 1 unit only
- IoT Central: `Standard 0`, `Standard 1`
- Device Provisioning Service: `S1` / `Standard` / 1 unit

### App Configuration

- `Free`, `Developer`
