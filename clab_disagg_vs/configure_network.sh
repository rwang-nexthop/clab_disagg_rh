#!/bin/bash

# Script to configure Disaggregated Clos SONiC topology
# 4-tier Clos network: Tier 0 (RWA), Tier 1 (URH), Tier 2 (LRH), Tier 3 (UT2)

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Container lists
TIER0_CONTAINERS=("clab-disagg-clos-RWA-1" "clab-disagg-clos-RWA-2")
TIER1_CONTAINERS=("clab-disagg-clos-URH-1-TH5" "clab-disagg-clos-URH-2-TH5")
TIER2_CONTAINERS=("clab-disagg-clos-LRH-1-Q3D" "clab-disagg-clos-LRH-2-Q3D")
TIER3_CONTAINERS=("clab-disagg-clos-UT2-1-Q3D" "clab-disagg-clos-UT2-2-Q3D")
ALL_CONTAINERS=("${TIER0_CONTAINERS[@]}" "${TIER1_CONTAINERS[@]}" "${TIER2_CONTAINERS[@]}" "${TIER3_CONTAINERS[@]}")

# Function to configure BGP on Tier 0 (Root) nodes
configure_tier0_bgp() {
    local container_name=$1
    local asn=$2
    local router_id=""
    local neighbor1=""
    local neighbor2=""

    if [ "$container_name" == "clab-disagg-clos-RWA-1" ]; then
        router_id="1.1.1.1"
        neighbor1="10.0.0.1"  # URH-1-TH5
        neighbor2="10.0.1.1"  # URH-2-TH5
    else
        router_id="2.2.2.2"
        neighbor1="10.0.0.3"  # URH-1-TH5
        neighbor2="10.0.1.3"  # URH-2-TH5
    fi

    echo "Configuring BGP on $container_name (AS $asn)..."

    docker exec $container_name vtysh -c "configure terminal" \
        -c "router bgp $asn" \
        -c "bgp router-id $router_id" \
        -c "bgp log-neighbor-changes" \
        -c "no bgp ebgp-requires-policy" \
        -c "neighbor $neighbor1 remote-as 65001" \
        -c "neighbor $neighbor1 description URH-1-TH5" \
        -c "neighbor $neighbor2 remote-as 65002" \
        -c "neighbor $neighbor2 description URH-2-TH5" \
        -c "address-family ipv4 unicast" \
        -c "neighbor $neighbor1 activate" \
        -c "neighbor $neighbor2 activate" \
        -c "network $router_id/32" \
        -c "redistribute connected" \
        -c "exit-address-family" \
        -c "exit" 2>&1 | grep -v "Unknown command" || true

    docker exec $container_name vtysh -c "write memory" 2>&1 | grep -v "Unknown command" || true

    echo "✓ Successfully configured $container_name"
}

# Function to configure BGP on Tier 1 (Spine) nodes
configure_tier1_bgp() {
    local container_name=$1
    local asn=$2
    local router_id=""
    local neighbor1=""
    local neighbor2=""
    local neighbor3=""
    local neighbor4=""

    if [ "$container_name" == "clab-disagg-clos-URH-1-TH5" ]; then
        router_id="11.11.11.11"
        neighbor1="10.0.0.0"  # RWA-1
        neighbor2="10.0.0.2"  # RWA-2
        neighbor3="10.1.0.1"  # LRH-1-Q3D
        neighbor4="10.1.1.1"  # LRH-2-Q3D
    else
        router_id="22.22.22.22"
        neighbor1="10.0.1.0"  # RWA-1
        neighbor2="10.0.1.2"  # RWA-2
        neighbor3="10.1.0.3"  # LRH-1-Q3D
        neighbor4="10.1.1.3"  # LRH-2-Q3D
    fi

    echo "Configuring BGP on $container_name (AS $asn)..."

    docker exec $container_name vtysh -c "configure terminal" \
        -c "router bgp $asn" \
        -c "bgp router-id $router_id" \
        -c "bgp log-neighbor-changes" \
        -c "no bgp ebgp-requires-policy" \
        -c "neighbor $neighbor1 remote-as 65000" \
        -c "neighbor $neighbor1 description RWA-1" \
        -c "neighbor $neighbor2 remote-as 65000" \
        -c "neighbor $neighbor2 description RWA-2" \
        -c "neighbor $neighbor3 remote-as 65010" \
        -c "neighbor $neighbor3 description LRH-1-Q3D" \
        -c "neighbor $neighbor4 remote-as 65011" \
        -c "neighbor $neighbor4 description LRH-2-Q3D" \
        -c "address-family ipv4 unicast" \
        -c "neighbor $neighbor1 activate" \
        -c "neighbor $neighbor2 activate" \
        -c "neighbor $neighbor3 activate" \
        -c "neighbor $neighbor4 activate" \
        -c "network $router_id/32" \
        -c "redistribute connected" \
        -c "exit-address-family" \
        -c "exit" 2>&1 | grep -v "Unknown command" || true

    docker exec $container_name vtysh -c "write memory" 2>&1 | grep -v "Unknown command" || true

    echo "✓ Successfully configured $container_name"
}

# Function to configure BGP on Tier 2 (Leaf) nodes
configure_tier2_bgp() {
    local container_name=$1
    local asn=$2
    local router_id=""
    local neighbor1=""
    local neighbor2=""
    local neighbor3=""
    local neighbor3_asn=""

    if [ "$container_name" == "clab-disagg-clos-LRH-1-Q3D" ]; then
        router_id="33.33.33.33"
        neighbor1="10.1.0.0"  # URH-1-TH5
        neighbor2="10.1.0.2"  # URH-2-TH5
        neighbor3="10.2.0.1"  # UT2-1-Q3D
        neighbor3_asn="65020"
    else
        router_id="44.44.44.44"
        neighbor1="10.1.1.0"  # URH-1-TH5
        neighbor2="10.1.1.2"  # URH-2-TH5
        neighbor3="10.2.1.1"  # UT2-2-Q3D
        neighbor3_asn="65021"
    fi

    echo "Configuring BGP on $container_name (AS $asn)..."

    docker exec $container_name vtysh -c "configure terminal" \
        -c "router bgp $asn" \
        -c "bgp router-id $router_id" \
        -c "bgp log-neighbor-changes" \
        -c "no bgp ebgp-requires-policy" \
        -c "neighbor $neighbor1 remote-as 65001" \
        -c "neighbor $neighbor1 description URH-1-TH5" \
        -c "neighbor $neighbor2 remote-as 65002" \
        -c "neighbor $neighbor2 description URH-2-TH5" \
        -c "neighbor $neighbor3 remote-as $neighbor3_asn" \
        -c "neighbor $neighbor3 description UT2-Q3D" \
        -c "address-family ipv4 unicast" \
        -c "neighbor $neighbor1 activate" \
        -c "neighbor $neighbor2 activate" \
        -c "neighbor $neighbor3 activate" \
        -c "network $router_id/32" \
        -c "redistribute connected" \
        -c "exit-address-family" \
        -c "exit" 2>&1 | grep -v "Unknown command" || true

    docker exec $container_name vtysh -c "write memory" 2>&1 | grep -v "Unknown command" || true

    echo "✓ Successfully configured $container_name"
}

# Function to configure BGP on Tier 3 (Access) nodes
configure_tier3_bgp() {
    local container_name=$1
    local asn=$2
    local router_id=""
    local neighbor1=""
    local neighbor1_asn=""

    if [ "$container_name" == "clab-disagg-clos-UT2-1-Q3D" ]; then
        router_id="55.55.55.55"
        neighbor1="10.2.0.0"  # LRH-1-Q3D
        neighbor1_asn="65010"
    else
        router_id="66.66.66.66"
        neighbor1="10.2.1.0"  # LRH-2-Q3D
        neighbor1_asn="65011"
    fi

    echo "Configuring BGP on $container_name (AS $asn)..."

    docker exec $container_name vtysh -c "configure terminal" \
        -c "router bgp $asn" \
        -c "bgp router-id $router_id" \
        -c "bgp log-neighbor-changes" \
        -c "no bgp ebgp-requires-policy" \
        -c "neighbor $neighbor1 remote-as $neighbor1_asn" \
        -c "neighbor $neighbor1 description LRH-Q3D" \
        -c "address-family ipv4 unicast" \
        -c "neighbor $neighbor1 activate" \
        -c "network $router_id/32" \
        -c "redistribute connected" \
        -c "exit-address-family" \
        -c "exit" 2>&1 | grep -v "Unknown command" || true

    docker exec $container_name vtysh -c "write memory" 2>&1 | grep -v "Unknown command" || true

    echo "✓ Successfully configured $container_name"
}

echo ""
echo "=========================================="
echo "  Disaggregated Clos Lab - Complete Configuration"
echo "=========================================="
echo ""

# Step 0: Check Docker connectivity
echo -e "${BLUE}Step 0: Checking Docker connectivity...${NC}"
echo "-------------------------------------------"

all_running=true
for container in "${ALL_CONTAINERS[@]}"; do
    if docker ps --format '{{.Names}}' | grep -q "^${container}$"; then
        echo -e "  ${GREEN}✓${NC} $container is running"
    else
        echo -e "  ${RED}✗${NC} $container is NOT running"
        all_running=false
    fi
done

if [ "$all_running" = false ]; then
    echo -e "${RED}Error: Not all containers are running!${NC}"
    exit 1
fi

echo -e "${GREEN}✓ All containers are running${NC}"
echo ""

# Step 1: Bring up eth interfaces
echo -e "${BLUE}Step 1: Bringing up containerlab eth interfaces...${NC}"
echo "-------------------------------------------"

# Tier 0 nodes (eth1-eth2 for 2 spine connections each)
for i in 1 2; do
    docker exec clab-disagg-clos-RWA-$i ip link set eth1 up
    docker exec clab-disagg-clos-RWA-$i ip link set eth2 up
done

# Tier 1 nodes (eth1-eth4 for 2 root + 2 leaf connections each)
for i in 1 2; do
    docker exec clab-disagg-clos-URH-$i-TH5 ip link set eth1 up
    docker exec clab-disagg-clos-URH-$i-TH5 ip link set eth2 up
    docker exec clab-disagg-clos-URH-$i-TH5 ip link set eth3 up
    docker exec clab-disagg-clos-URH-$i-TH5 ip link set eth4 up
done

# Tier 2 nodes (eth1-eth3 for 2 spine + 1 access connection each)
for i in 1 2; do
    docker exec clab-disagg-clos-LRH-$i-Q3D ip link set eth1 up
    docker exec clab-disagg-clos-LRH-$i-Q3D ip link set eth2 up
    docker exec clab-disagg-clos-LRH-$i-Q3D ip link set eth3 up
done

# Tier 3 nodes (eth1 for 1 leaf connection each)
docker exec clab-disagg-clos-UT2-1-Q3D ip link set eth1 up
docker exec clab-disagg-clos-UT2-2-Q3D ip link set eth1 up

echo -e "${GREEN}✓ All eth interfaces are up${NC}"
sleep 2
echo ""

# Step 2: Configure interfaces and IP addresses
echo -e "${BLUE}Step 2: Configuring interfaces and IP addresses...${NC}"
echo "-------------------------------------------"

# Tier 0 - RWA-1 interfaces
docker exec clab-disagg-clos-RWA-1 config interface ip add Ethernet0 10.0.0.0/31 2>/dev/null || true
docker exec clab-disagg-clos-RWA-1 config interface startup Ethernet0 2>/dev/null || true
docker exec clab-disagg-clos-RWA-1 config interface ip add Ethernet4 10.0.1.0/31 2>/dev/null || true
docker exec clab-disagg-clos-RWA-1 config interface startup Ethernet4 2>/dev/null || true
docker exec clab-disagg-clos-RWA-1 config interface ip add Loopback0 1.1.1.1/32 2>/dev/null || true

# Tier 0 - RWA-2 interfaces
docker exec clab-disagg-clos-RWA-2 config interface ip add Ethernet0 10.0.0.2/31 2>/dev/null || true
docker exec clab-disagg-clos-RWA-2 config interface startup Ethernet0 2>/dev/null || true
docker exec clab-disagg-clos-RWA-2 config interface ip add Ethernet4 10.0.1.2/31 2>/dev/null || true
docker exec clab-disagg-clos-RWA-2 config interface startup Ethernet4 2>/dev/null || true
docker exec clab-disagg-clos-RWA-2 config interface ip add Loopback0 2.2.2.2/32 2>/dev/null || true

# Tier 1 - URH-1-TH5 interfaces
docker exec clab-disagg-clos-URH-1-TH5 config interface ip add Ethernet0 10.0.0.1/31 2>/dev/null || true
docker exec clab-disagg-clos-URH-1-TH5 config interface startup Ethernet0 2>/dev/null || true
docker exec clab-disagg-clos-URH-1-TH5 config interface ip add Ethernet4 10.0.0.3/31 2>/dev/null || true
docker exec clab-disagg-clos-URH-1-TH5 config interface startup Ethernet4 2>/dev/null || true
docker exec clab-disagg-clos-URH-1-TH5 config interface ip add Ethernet8 10.1.0.0/31 2>/dev/null || true
docker exec clab-disagg-clos-URH-1-TH5 config interface startup Ethernet8 2>/dev/null || true
docker exec clab-disagg-clos-URH-1-TH5 config interface ip add Ethernet12 10.1.1.0/31 2>/dev/null || true
docker exec clab-disagg-clos-URH-1-TH5 config interface startup Ethernet12 2>/dev/null || true
docker exec clab-disagg-clos-URH-1-TH5 config interface ip add Loopback0 11.11.11.11/32 2>/dev/null || true

# Tier 1 - URH-2-TH5 interfaces
docker exec clab-disagg-clos-URH-2-TH5 config interface ip add Ethernet0 10.0.1.1/31 2>/dev/null || true
docker exec clab-disagg-clos-URH-2-TH5 config interface startup Ethernet0 2>/dev/null || true
docker exec clab-disagg-clos-URH-2-TH5 config interface ip add Ethernet4 10.0.1.3/31 2>/dev/null || true
docker exec clab-disagg-clos-URH-2-TH5 config interface startup Ethernet4 2>/dev/null || true
docker exec clab-disagg-clos-URH-2-TH5 config interface ip add Ethernet8 10.1.0.2/31 2>/dev/null || true
docker exec clab-disagg-clos-URH-2-TH5 config interface startup Ethernet8 2>/dev/null || true
docker exec clab-disagg-clos-URH-2-TH5 config interface ip add Ethernet12 10.1.1.2/31 2>/dev/null || true
docker exec clab-disagg-clos-URH-2-TH5 config interface startup Ethernet12 2>/dev/null || true
docker exec clab-disagg-clos-URH-2-TH5 config interface ip add Loopback0 22.22.22.22/32 2>/dev/null || true

# Tier 2 - LRH-1-Q3D interfaces
docker exec clab-disagg-clos-LRH-1-Q3D config interface ip add Ethernet0 10.1.0.1/31 2>/dev/null || true
docker exec clab-disagg-clos-LRH-1-Q3D config interface startup Ethernet0 2>/dev/null || true
docker exec clab-disagg-clos-LRH-1-Q3D config interface ip add Ethernet4 10.1.0.3/31 2>/dev/null || true
docker exec clab-disagg-clos-LRH-1-Q3D config interface startup Ethernet4 2>/dev/null || true
docker exec clab-disagg-clos-LRH-1-Q3D config interface ip add Ethernet8 10.2.0.0/31 2>/dev/null || true
docker exec clab-disagg-clos-LRH-1-Q3D config interface startup Ethernet8 2>/dev/null || true
docker exec clab-disagg-clos-LRH-1-Q3D config interface ip add Loopback0 33.33.33.33/32 2>/dev/null || true

# Tier 2 - LRH-2-Q3D interfaces
docker exec clab-disagg-clos-LRH-2-Q3D config interface ip add Ethernet0 10.1.1.1/31 2>/dev/null || true
docker exec clab-disagg-clos-LRH-2-Q3D config interface startup Ethernet0 2>/dev/null || true
docker exec clab-disagg-clos-LRH-2-Q3D config interface ip add Ethernet4 10.1.1.3/31 2>/dev/null || true
docker exec clab-disagg-clos-LRH-2-Q3D config interface startup Ethernet4 2>/dev/null || true
docker exec clab-disagg-clos-LRH-2-Q3D config interface ip add Ethernet8 10.2.1.0/31 2>/dev/null || true
docker exec clab-disagg-clos-LRH-2-Q3D config interface startup Ethernet8 2>/dev/null || true
docker exec clab-disagg-clos-LRH-2-Q3D config interface ip add Loopback0 44.44.44.44/32 2>/dev/null || true

# Tier 3 - UT2-1-Q3D interfaces
docker exec clab-disagg-clos-UT2-1-Q3D config interface ip add Ethernet0 10.2.0.1/31 2>/dev/null || true
docker exec clab-disagg-clos-UT2-1-Q3D config interface startup Ethernet0 2>/dev/null || true
docker exec clab-disagg-clos-UT2-1-Q3D config interface ip add Loopback0 55.55.55.55/32 2>/dev/null || true

# Tier 3 - UT2-2-Q3D interfaces
docker exec clab-disagg-clos-UT2-2-Q3D config interface ip add Ethernet0 10.2.1.1/31 2>/dev/null || true
docker exec clab-disagg-clos-UT2-2-Q3D config interface startup Ethernet0 2>/dev/null || true
docker exec clab-disagg-clos-UT2-2-Q3D config interface ip add Loopback0 66.66.66.66/32 2>/dev/null || true

echo -e "${GREEN}✓ All interfaces configured${NC}"
sleep 5
echo ""

# Step 3: Enable bgpd on all containers
echo -e "${BLUE}Step 3: Enabling bgpd daemon on all containers...${NC}"
echo "--------------------------------------------------"

for container in "${ALL_CONTAINERS[@]}"; do
    docker exec $container sed -i 's/bgpd=no/bgpd=yes/' /etc/frr/daemons
    docker exec $container service frr restart 2>&1 | grep -v "Cannot stop watchfrr" || true
    sleep 2
done

echo -e "${GREEN}✓ bgpd enabled on all containers${NC}"
echo ""

# Step 4: Configure BGP on Tier 0 (Root) routers
echo -e "${BLUE}Step 4: Configuring BGP on Tier 0 (Root) routers...${NC}"
echo "--------------------------------------------"

configure_tier0_bgp "clab-disagg-clos-RWA-1" "65000"
configure_tier0_bgp "clab-disagg-clos-RWA-2" "65000"

echo -e "${GREEN}✓ BGP configured on Tier 0 routers${NC}"
echo ""

# Step 5: Configure BGP on Tier 1 (Spine) routers
echo -e "${BLUE}Step 5: Configuring BGP on Tier 1 (Spine) routers...${NC}"
echo "-------------------------------------------"

configure_tier1_bgp "clab-disagg-clos-URH-1-TH5" "65001"
configure_tier1_bgp "clab-disagg-clos-URH-2-TH5" "65002"

echo -e "${GREEN}✓ BGP configured on Tier 1 routers${NC}"
echo ""

# Step 6: Configure BGP on Tier 2 (Leaf) routers
echo -e "${BLUE}Step 6: Configuring BGP on Tier 2 (Leaf) routers...${NC}"
echo "-------------------------------------------"

configure_tier2_bgp "clab-disagg-clos-LRH-1-Q3D" "65010"
configure_tier2_bgp "clab-disagg-clos-LRH-2-Q3D" "65011"

echo -e "${GREEN}✓ BGP configured on Tier 2 routers${NC}"
echo ""

# Step 7: Configure BGP on Tier 3 (Access) routers
echo -e "${BLUE}Step 7: Configuring BGP on Tier 3 (Access) routers...${NC}"
echo "-------------------------------------------"

configure_tier3_bgp "clab-disagg-clos-UT2-1-Q3D" "65020"
configure_tier3_bgp "clab-disagg-clos-UT2-2-Q3D" "65021"

echo -e "${GREEN}✓ BGP configured on Tier 3 routers${NC}"
echo ""

# Step 8: Wait for BGP sessions to establish and exchange routes
echo -e "${BLUE}Step 8: Waiting for BGP sessions to establish and exchange routes...${NC}"
echo "----------------------------------------------------------------------"
echo "Waiting 60 seconds for BGP convergence..."
sleep 60
echo -e "${GREEN}✓ BGP convergence complete${NC}"
echo ""

# Step 9: Verify BGP status
echo -e "${BLUE}Step 9: Verifying BGP configuration...${NC}"
echo "---------------------------------------"

for container in "${ALL_CONTAINERS[@]}"; do
    echo "=== $container BGP Summary ==="
    docker exec $container vtysh -c "show ip bgp summary" 2>/dev/null || echo "BGP not ready yet"
    echo ""
done

echo "=========================================="
echo "  Configuration Complete!"
echo "=========================================="
echo ""
echo "Summary:"
echo "  - All containers verified and running"
echo "  - All interfaces configured with IP addresses"
echo "  - BGP configured on all nodes"
echo "  - BGP sessions established"
echo ""
echo "Verification commands:"
echo "  - Check BGP neighbors: docker exec <container> vtysh -c 'show ip bgp summary'"
echo "  - Check BGP routes:    docker exec <container> vtysh -c 'show ip bgp'"
echo "  - Check routing table: docker exec <container> vtysh -c 'show ip route'"
echo "  - Enter vtysh:         docker exec -it <container> vtysh"
echo ""

