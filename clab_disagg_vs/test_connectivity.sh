#!/bin/bash

# Connectivity Test Script for Disaggregated Clos Topology
# Tests all tiers and BGP connectivity using docker exec

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo ""
echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║              Disaggregated Clos Topology - Connectivity Tests                 ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Test 1: Tier 0 to Tier 1 connectivity
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Test 1: Tier 0 (Root) to Tier 1 (Spine) Direct Connectivity${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo ""

echo -e "${YELLOW}RWA-1 (10.0.0.0) → URH-1-TH5 (10.0.0.1):${NC}"
docker exec clab-disagg-clos-RWA-1 ping -c 3 10.0.0.1 2>/dev/null | head -4
echo ""

echo -e "${YELLOW}RWA-1 (10.0.1.0) → URH-2-TH5 (10.0.1.1):${NC}"
docker exec clab-disagg-clos-RWA-1 ping -c 3 10.0.1.1 2>/dev/null | head -4
echo ""

# Test 2: Tier 1 to Tier 2 connectivity
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Test 2: Tier 1 (Spine) to Tier 2 (Leaf) Direct Connectivity${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo ""

echo -e "${YELLOW}URH-1-TH5 (10.1.0.0) → LRH-1-Q3D (10.1.0.1):${NC}"
docker exec clab-disagg-clos-URH-1-TH5 ping -c 3 10.1.0.1 2>/dev/null | head -4
echo ""

echo -e "${YELLOW}URH-1-TH5 (10.1.1.0) → LRH-2-Q3D (10.1.1.1):${NC}"
docker exec clab-disagg-clos-URH-1-TH5 ping -c 3 10.1.1.1 2>/dev/null | head -4
echo ""

# Test 3: Tier 2 to Tier 3 connectivity
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Test 3: Tier 2 (Leaf) to Tier 3 (Access) Direct Connectivity${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo ""

echo -e "${YELLOW}LRH-1-Q3D (10.2.0.0) → UT2-1-Q3D (10.2.0.1):${NC}"
docker exec clab-disagg-clos-LRH-1-Q3D ping -c 3 10.2.0.1 2>/dev/null | head -4
echo ""

echo -e "${YELLOW}LRH-2-Q3D (10.2.1.0) → UT2-2-Q3D (10.2.1.1):${NC}"
docker exec clab-disagg-clos-LRH-2-Q3D ping -c 3 10.2.1.1 2>/dev/null | head -4
echo ""

# Test 4: End-to-end interface connectivity
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Test 4: End-to-End Interface Connectivity (via BGP routes)${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo ""

echo -e "${YELLOW}UT2-1-Q3D → RWA-1 Interface (10.0.0.0):${NC}"
docker exec clab-disagg-clos-UT2-1-Q3D ping -c 3 10.0.0.0 2>/dev/null | head -4
echo ""

echo -e "${YELLOW}UT2-1-Q3D → RWA-2 Interface (10.0.0.2):${NC}"
docker exec clab-disagg-clos-UT2-1-Q3D ping -c 3 10.0.0.2 2>/dev/null | head -4
echo ""

echo -e "${YELLOW}UT2-2-Q3D → RWA-1 Interface (10.0.1.0):${NC}"
docker exec clab-disagg-clos-UT2-2-Q3D ping -c 3 10.0.1.0 2>/dev/null | head -4
echo ""

echo -e "${YELLOW}UT2-2-Q3D → RWA-2 Interface (10.0.1.2):${NC}"
docker exec clab-disagg-clos-UT2-2-Q3D ping -c 3 10.0.1.2 2>/dev/null | head -4
echo ""

echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Connectivity Tests Complete!${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo ""

