#!/bin/bash

# Comprehensive connectivity test script for Disaggregated Clos topology
# Tests all tiers and BGP connectivity using SSH

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# SSH options for SONiC nodes - use password authentication with sshpass
SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=5"
SSHPASS="sshpass -p admin"

echo ""
echo "╔═══════════════════════════════════════════════════════════════════════════════╗"
echo "║              Disaggregated Clos Topology - Connectivity Tests                 ║"
echo "╚═══════════════════════════════════════════════════════════════════════════════╝"
echo ""

# Test 1: Tier 0 to Tier 1 connectivity
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Test 1: Tier 0 (Root) to Tier 1 (Spine) Direct Connectivity${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo ""

echo -e "${YELLOW}RWA-1 (10.0.0.0) → URH-1-TH5 (10.0.0.1):${NC}"
PING_OUT=$($SSHPASS ssh $SSH_OPTS admin@clab-disagg-clos-RWA-1 "ping -c 3 10.0.0.1" 2>/dev/null)
echo "$PING_OUT" | head -4
if echo "$PING_OUT" | grep -q "0% packet loss"; then echo -e "${GREEN}✓ PASS${NC}"; else echo -e "${RED}✗ FAIL${NC}"; fi
echo ""

echo -e "${YELLOW}RWA-1 (10.0.1.0) → URH-2-TH5 (10.0.1.1):${NC}"
PING_OUT=$($SSHPASS ssh $SSH_OPTS admin@clab-disagg-clos-RWA-1 "ping -c 3 10.0.1.1" 2>/dev/null)
echo "$PING_OUT" | head -4
if echo "$PING_OUT" | grep -q "0% packet loss"; then echo -e "${GREEN}✓ PASS${NC}"; else echo -e "${RED}✗ FAIL${NC}"; fi
echo ""

# Test 2: Tier 1 to Tier 2 connectivity
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Test 2: Tier 1 (Spine) to Tier 2 (Leaf) Direct Connectivity${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo ""

echo -e "${YELLOW}URH-1-TH5 (10.1.0.0) → LRH-1-Q3D (10.1.0.1):${NC}"
PING_OUT=$($SSHPASS ssh $SSH_OPTS admin@clab-disagg-clos-URH-1-TH5 "ping -c 3 10.1.0.1" 2>/dev/null)
echo "$PING_OUT" | head -4
if echo "$PING_OUT" | grep -q "0% packet loss"; then echo -e "${GREEN}✓ PASS${NC}"; else echo -e "${RED}✗ FAIL${NC}"; fi
echo ""

echo -e "${YELLOW}URH-1-TH5 (10.1.1.0) → LRH-2-Q3D (10.1.1.1):${NC}"
PING_OUT=$($SSHPASS ssh $SSH_OPTS admin@clab-disagg-clos-URH-1-TH5 "ping -c 3 10.1.1.1" 2>/dev/null)
echo "$PING_OUT" | head -4
if echo "$PING_OUT" | grep -q "0% packet loss"; then echo -e "${GREEN}✓ PASS${NC}"; else echo -e "${RED}✗ FAIL${NC}"; fi
echo ""

# Test 3: Tier 2 to Tier 3 connectivity
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Test 3: Tier 2 (Leaf) to Tier 3 (Access) Direct Connectivity${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo ""

echo -e "${YELLOW}LRH-1-Q3D (10.2.0.0) → UT2-1-Q3D (10.2.0.1):${NC}"
PING_OUT=$($SSHPASS ssh $SSH_OPTS admin@clab-disagg-clos-LRH-1-Q3D "ping -c 3 10.2.0.1" 2>/dev/null)
echo "$PING_OUT" | head -4
if echo "$PING_OUT" | grep -q "0% packet loss"; then echo -e "${GREEN}✓ PASS${NC}"; else echo -e "${RED}✗ FAIL${NC}"; fi
echo ""

echo -e "${YELLOW}LRH-2-Q3D (10.2.1.0) → UT2-2-Q3D (10.2.1.1):${NC}"
PING_OUT=$($SSHPASS ssh $SSH_OPTS admin@clab-disagg-clos-LRH-2-Q3D "ping -c 3 10.2.1.1" 2>/dev/null)
echo "$PING_OUT" | head -4
if echo "$PING_OUT" | grep -q "0% packet loss"; then echo -e "${GREEN}✓ PASS${NC}"; else echo -e "${RED}✗ FAIL${NC}"; fi
echo ""

# Test 5: BGP Session Status
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Test 5: BGP Session Status${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo ""

echo -e "${YELLOW}RWA-1 BGP Summary:${NC}"
$SSHPASS ssh $SSH_OPTS admin@clab-disagg-clos-RWA-1 "vtysh -c 'show ip bgp summary'" 2>/dev/null || echo "BGP not ready"
echo ""

echo -e "${YELLOW}URH-1-TH5 BGP Summary:${NC}"
$SSHPASS ssh $SSH_OPTS admin@clab-disagg-clos-URH-1-TH5 "vtysh -c 'show ip bgp summary'" 2>/dev/null || echo "BGP not ready"
echo ""

echo -e "${YELLOW}LRH-1-Q3D BGP Summary:${NC}"
$SSHPASS ssh $SSH_OPTS admin@clab-disagg-clos-LRH-1-Q3D "vtysh -c 'show ip bgp summary'" 2>/dev/null || echo "BGP not ready"
echo ""

echo -e "${YELLOW}UT2-1-Q3D BGP Summary:${NC}"
$SSHPASS ssh $SSH_OPTS admin@clab-disagg-clos-UT2-1-Q3D "vtysh -c 'show ip bgp summary'" 2>/dev/null || echo "BGP not ready"
echo ""

echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Connectivity Tests Complete!${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo ""

