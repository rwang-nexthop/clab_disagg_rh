# Disaggregated Clos Topology (SONiC-vs)

A 4-tier disaggregated Clos network topology using SONiC virtual switches deployed with Containerlab.

## Topology Overview

```
                                                                                                 
 ┌───────────────────────────────────────┐            ┌───────────────────────────────────────┐  
 │ RWA-1                                 │            │ RWA-2                                 │  
 │ Loopback0: 1.1.1.1/32                 │            │ Loopback0: 2.2.2.2/32                 │  
 │ Ethernet0: 10.0.0.0/31 (to URH-1-TH5) │            │ Ethernet0: 10.0.0.2/31 (to URH-1-TH5) │  
 │ Ethernet4: 10.0.1.0/31 (to URH-2-TH5) │            │ Ethernet4: 10.0.1.2/31 (to URH-2-TH5) │  
 │                                       │            │                                       │  
 └┬───────────────────────────────────┬──┘            └──┬───────────────────────────────────┬┘  
  │                                   │                  │                                   │   
  │                                   │                  │                                   │   
  │                                 ┌─┼──────────────────┘                                   │   
  │                                 │ │                                                      │   
  │                                 │ └────────────────────┐                                 │   
  │                                 │                      │                                 │   
  │                                 │                      │                                 │   
  │                                 │                      │                                 │   
  │                                 │                      │                                 │   
 ┌▼─────────────────────────────────▼─────┐            ┌───▼─────────────────────────────────▼─┐ 
 │ URH-1-TH5 - ASN 65001                  │            │URH-2-TH5 - ASN 65002                  │ 
 │ Loopback0: 11.11.11.11/32              │            │Loopback0: 22.22.22.22/32              │ 
 │ Ethernet0: 10.0.0.1/31 (to RWA-1)      │            │Ethernet0: 10.0.1.1/31 (to RWA-1)      │ 
 │ Ethernet4: 10.0.0.3/31 (to RWA-2)      │            │Ethernet4: 10.0.1.3/31 (to RWA-2)      │ 
 │ Ethernet8: 10.1.0.0/31 (to LRH-1-Q3D)  │            │Ethernet8: 10.1.0.2/31 (to LRH-1-Q3D)  │ 
 │ Ethernet12: 10.1.1.0/31 (to LRH-2-Q3D) │            │Ethernet12: 10.1.1.2/31 (to LRH-2-Q3D) │ 
 └┬────────────────────────────────────┬──┘            └──┬──────────────────────────────────┬─┘ 
  │                                    │                  │                                  │   
  │                                    │                  │                                  │   
  │                                 ┌──┼──────────────────┘                                  │   
  │                                 │  │                                                     │   
  │                                 │  └──────────────────┐                                  │   
  │                                 │                     │                                  │   
  │                                 │                     │                                  │   
 ┌▼─────────────────────────────────▼─────┐           ┌───▼──────────────────────────────────▼─┐ 
 │ LRH-1-Q3D - ASN 65010                  │           │ LRH-2-Q3D - ASN 65011                  │ 
 │ Loopback0: 33.33.33.33/32              │           │ Loopback0: 44.44.44.44/32              │ 
 │ Ethernet0: 10.1.0.1/31 (to URH-1-TH5)  │           │ Ethernet0: 10.1.1.1/31 (to URH-1-TH5)  │ 
 │ Ethernet4: 10.1.0.3/31 (to URH-2-TH5)  │           │ Ethernet4: 10.1.1.3/31 (to URH-2-TH5)  │ 
 │ Ethernet8: 10.2.0.0/31 (to UT2-1-Q3D)  │           │ Ethernet8: 10.2.1.0/31 (to UT2-2-Q3D)  │ 
 └┬───────────────────────────────────────┘           └──────────────────────────────────────┬─┘ 
  │                                                                                          │   
  │                                                                                          │   
  │                                                                                          │   
  │                                                                                          │   
  │                                                                                          │   
  │                                                                                          │   
 ┌▼───────────────────────────────────────┐           ┌──────────────────────────────────────▼─┐ 
 │ UT2-1-Q3D - ASN 65020                  │           │ UT2 2-Q3D - ASN 65021                  │ 
 │ Loopback0: 55.55.55.55/32              │           │ Loopback0: 66.66.66.66/32              │ 
 │ Ethernet0: 10.2.0.1/31 (to LRH-1-Q3D)  │           │ Ethernet0: 10.2.1.1/31 (to LRH-2-Q3D)  │ 
 │                                        │           │                                        │ 
 └────────────────────────────────────────┘           └────────────────────────────────────────┘ 
                                                                                                 
```

## Network Details

### Tier 0 (Root Nodes)
- **RWA-1**: ASN 65000, Router ID 1.1.1.1
- **RWA-2**: ASN 65000, Router ID 2.2.2.2

### Tier 1 (Spine Nodes)
- **URH-1-TH5**: ASN 65001, Router ID 11.11.11.11
- **URH-2-TH5**: ASN 65002, Router ID 22.22.22.22

### Tier 2 (Leaf Nodes)
- **LRH-1-Q3D**: ASN 65010, Router ID 33.33.33.33
- **LRH-2-Q3D**: ASN 65011, Router ID 44.44.44.44

### Tier 3 (Access Nodes)
- **UT2-1-Q3D**: ASN 65020, Router ID 55.55.55.55
- **UT2-2-Q3D**: ASN 65021, Router ID 66.66.66.66

## Deployment

### Prerequisites
- Containerlab installed
- Docker with SONiC-vs image available
- `docker` command available in PATH

### Deploy the Topology

```bash
cd Projects/clab_disagg_vs
sudo clab deploy -t disagg-clos.clab.yml
```

### Configure Network (Interfaces & BGP)

```bash
bash configure_network.sh
```

This single script configures all nodes using `docker exec`:
- Brings up containerlab eth interfaces (eth1-eth4)
- Enables bgpd daemon on all containers
- Configures all interface IP addresses using `vtysh`
- Configures loopback interfaces for each node
- Configures BGP with proper ASNs and router IDs using `vtysh`
- Configures BGP route advertisements for loopback networks
- Waits 5 seconds for BGP convergence
- Verifies BGP status on all nodes

## Testing

### Run Connectivity Tests

```bash
bash test_connectivity.sh
```

This script tests:
1. **Tier 0 to Tier 1**: Direct connectivity between root and spine nodes
2. **Tier 1 to Tier 2**: Direct connectivity between spine and leaf nodes
3. **Tier 2 to Tier 3**: Direct connectivity between leaf and access nodes
4. **End-to-End**: Loopback reachability via BGP routes across all tiers

## Cleanup

```bash
sudo clab destroy -t disagg-clos.clab.yml
```

## Notes

- All BGP configuration is done dynamically via scripts (no static config files)
- Loopback interfaces are configured with /32 addresses for each node
- BGP is configured to advertise loopback networks for end-to-end connectivity
- The topology uses a full Clos mesh at each tier level for redundancy

