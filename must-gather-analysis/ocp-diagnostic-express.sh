#!/bin/bash

#####################################################################
# OpenShift Diagnostic Helper - Express Mode
# Purpose: Quick diagnostic prompt generation with minimal interaction
# Usage: ./ocp-diagnostic-express.sh <must-gather-path> "<symptom>" "<affected-component>"
#####################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

#####################################################################
# Functions
#####################################################################

print_error() {
    echo -e "${RED}✗ Error: $1${NC}" >&2
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ $1${NC}"
}

usage() {
    cat << EOF
${BOLD}OpenShift Diagnostic Helper - Express Mode${NC}

${CYAN}Usage:${NC}
  $0 <must-gather-path> "<symptom>" "<affected-component>"

${CYAN}Arguments:${NC}
  must-gather-path    Path to must-gather directory
  symptom            Primary issue/symptom (in quotes)
  affected-component  Affected namespace/pod/operator (in quotes)

${CYAN}Examples:${NC}
  $0 ./must-gather.local.123/ "Pods in CrashLoopBackOff" "openshift-insights"

  $0 /data/mg/ "Authentication operator degraded" "authentication CO"

  $0 ~/must-gather/ "Nodes NotReady" "worker nodes"

${CYAN}Options:${NC}
  -h, --help         Show this help message
  -v, --verbose      Enable verbose output
  -o, --output FILE  Specify output file (default: diagnostic-prompt.md)

${CYAN}What it does:${NC}
  1. Auto-detects must-gather structure
  2. Runs quick analysis with omc (if available)
  3. Generates AI-ready diagnostic prompt
  4. Creates quick diagnostic script

${CYAN}For full interactive mode, use:${NC}
  ./ocp-diagnostic-helper.sh

EOF
    exit 0
}

#####################################################################
# Main Script
#####################################################################

# Parse arguments
VERBOSE=false
OUTPUT_FILE="diagnostic-prompt-express.md"

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -o|--output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        -*)
            print_error "Unknown option: $1"
            usage
            ;;
        *)
            break
            ;;
    esac
done

# Validate required arguments
if [ $# -lt 3 ]; then
    print_error "Missing required arguments"
    usage
fi

MG_PATH="$1"
SYMPTOM="$2"
AFFECTED="$3"

# Validate must-gather path
if [ ! -d "$MG_PATH" ]; then
    print_error "Must-gather path does not exist: $MG_PATH"
    exit 1
fi

# Find must-gather subdirectory
MG_DIR=$(find "$MG_PATH" -maxdepth 1 -type d -name "quay-io*" -o -name "registry*" 2>/dev/null | head -1)

if [ -z "$MG_DIR" ]; then
    # Try to use the provided path directly
    if [ -d "$MG_PATH/namespaces" ] || [ -d "$MG_PATH/cluster-scoped-resources" ]; then
        MG_DIR="$MG_PATH"
    else
        print_error "Could not find valid must-gather directory in: $MG_PATH"
        exit 1
    fi
fi

print_success "Must-gather directory: $MG_DIR"

# Auto-detect version
OCP_VERSION="unknown"
if [ -f "$MG_DIR/version" ]; then
    OCP_VERSION=$(head -1 "$MG_DIR/version")
    print_info "Detected version: $OCP_VERSION"
fi

# Auto-detect collection date
COLLECTION_DATE=$(date -r "$MG_DIR" +%Y-%m-%d 2>/dev/null || echo "unknown")

# Check for omc
HAS_OMC=false
if command -v omc &> /dev/null; then
    HAS_OMC=true
    print_success "OMC tool found"
else
    print_info "OMC tool not found - skipping quick analysis"
fi

# Run quick analysis if omc available
QUICK_ANALYSIS=""
if [ "$HAS_OMC" = true ]; then
    print_info "Running quick analysis..."

    ANALYSIS_FILE=$(mktemp)

    cd "$(dirname "$MG_DIR")"
    omc use "$(basename "$MG_DIR")" > /dev/null 2>&1

    {
        echo "### Quick Analysis Results"
        echo
        echo "**Degraded Cluster Operators:**"
        echo '```'
        omc get co 2>/dev/null | grep -v "True.*False.*False" || echo "None found"
        echo '```'
        echo
        echo "**Non-Ready Nodes:**"
        echo '```'
        omc get nodes 2>/dev/null | grep -v "Ready" | tail -n +2 || echo "None found"
        echo '```'
        echo
        echo "**Problematic Pods (Top 20):**"
        echo '```'
        omc get pods -A 2>/dev/null | grep -vE "Running|Completed|Success" | head -20 || echo "None found"
        echo '```'
        echo
    } > "$ANALYSIS_FILE"

    QUICK_ANALYSIS=$(cat "$ANALYSIS_FILE")
    rm -f "$ANALYSIS_FILE"

    print_success "Quick analysis complete"
fi

# Generate timestamp
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_FILE="${OUTPUT_FILE/.md/_${TIMESTAMP}.md}"

# Generate diagnostic prompt
print_info "Generating diagnostic prompt..."

cat > "$OUTPUT_FILE" << EOF
# OpenShift Cluster Diagnostic Analysis Request

**Generated**: $(date)
**Mode**: Express (Auto-generated)
**Must-Gather**: $(basename "$MG_DIR")

---

## Problem Context

### Symptom Description

**Primary symptom**: ${SYMPTOM}

**Affected components**: ${AFFECTED}

**Timeline**: Unknown (express mode)
**Frequency**: Unknown (express mode)

**Observable evidence**:
\`\`\`
User-reported issue (express mode - limited detail)
For detailed evidence, run full interactive mode: ./ocp-diagnostic-helper.sh
\`\`\`

${QUICK_ANALYSIS}

---

## Environment Information

### Must-Gather Location
- **Path**: \`$MG_DIR\`
- **Collection date**: ${COLLECTION_DATE}
- **OpenShift version**: ${OCP_VERSION}

### Tool Requirements
Use the following tools for cluster analysis:
- **omc (OpenShift Must-Gather Client)**: For querying must-gather data
  - Initialize with: \`omc use $(basename "$MG_DIR")\`
  - Working directory: \`$(dirname "$MG_DIR")\`

---

## Analysis Requirements

### Primary Focus Area
Comprehensive (all areas) - Auto-selected in express mode

### Specific Components
- **Namespaces**: ${AFFECTED}
- **Focus**: Based on symptom: "${SYMPTOM}"

### Recent Changes
Unknown (express mode)

### Business Impact
Medium (default - express mode)

---

## Analysis Framework

Follow the **OpenShift Troubleshooting Methodology**:

### 1. Start with the Phenomenon
- Begin with the specific symptom: ${SYMPTOM}
- Focus on affected components: ${AFFECTED}
- Expand investigation as needed

### 2. Utilize Tools
- Use must-gather to collect the global state
- Leverage omc for efficient data querying
- Cross-reference multiple data sources

### 3. Logical Reasoning

#### Top-Down Approach
1. **Application Layer** → Check pod status, logs, configurations
2. **Network Layer** → Verify service connectivity, DNS, routing
3. **Storage Layer** → Check PV/PVC status, storage operators
4. **Scheduling Layer** → Validate pod placement, resource availability
5. **Control Plane** → Review cluster operators, API server health

#### Bottom-Up Approach
1. **Operating System** → Check node conditions, kernel logs
2. **Node Resources** → CPU, memory, disk, PID pressure
3. **Container Runtime** → CRI-O/containerd health
4. **Kubelet** → Node agent logs and status
5. **Pod Layer** → Container status and application logs

### 4. Identify Root Cause
- Pinpoint specific, actionable root cause
- Distinguish symptoms from underlying issues
- Validate with supporting evidence

---

## Required Analysis Tasks

### Essential Diagnostic Steps

- [ ] **Cluster Health Overview**
  - \`omc get clusteroperators\`
  - \`omc get nodes\`
  - Check cluster version and upgrade history

- [ ] **Component Analysis for: ${AFFECTED}**
  - \`omc get pods -n <namespace>\`
  - \`omc describe pod <pod-name> -n <namespace>\`
  - \`omc logs pod/<pod-name> -n <namespace> -c <container>\`

- [ ] **Event Analysis**
  - \`omc get events -A | grep -E 'Warning|Error'\`
  - Focus on events related to: ${AFFECTED}
  - Identify patterns and frequency

- [ ] **Resource Analysis**
  - Check node resource allocation
  - Review pod resource requests/limits
  - Identify bottlenecks

- [ ] **Configuration Review**
  - Examine relevant configurations
  - Validate probe settings
  - Check for recent changes

- [ ] **Pattern Recognition**
  - Compare affected vs. healthy instances
  - Identify commonalities in failures
  - Assess temporal patterns

---

## Deliverable: Comprehensive Diagnostic Report

Generate a detailed report with:

### 1. Executive Summary
- Issue overview
- Root cause (1-2 sentences)
- Severity assessment

### 2. Cluster Information
- Platform, version, topology
- Overall health status

### 3. Problem Statement
- Detailed symptom description
- Affected components
- Timeline and frequency
- Current vs. expected state

### 4. Investigation Findings
- Cluster health analysis
- Component examination
- Event correlation
- Resource metrics
- Configuration issues

### 5. Root Cause Analysis
- Primary cause
- Contributing factors
- Supporting evidence
- Diagnostic methodology

### 6. Impact Assessment
- Functional impact
- Operational impact
- Risk assessment

### 7. Recommended Solution
- Immediate mitigation
- Permanent resolution
- Implementation steps
- Validation procedures

### 8. Validation Steps
- Post-fix monitoring
- Success criteria
- Rollback plan

### 9. Additional Observations
- Related findings
- Future risk areas
- Prevention recommendations

---

## Analysis Guidelines

### Best Practices
1. Use omc context: \`omc use <directory>\`
2. Investigate multiple data sources simultaneously
3. Base all conclusions on evidence
4. Distinguish correlation from causation
5. Check all affected instances, not just one

### Common Pitfalls to Avoid
- First error may not be root cause
- Healthy instances provide valuable contrast
- Event frequency indicates severity
- Dig deeper than symptoms
- Validate recommendations with data

---

## Task Execution Instructions

**Instruction to AI**:

Perform comprehensive diagnostic analysis using the must-gather snapshot at the specified location.

**Primary Focus**: ${SYMPTOM}
**Affected Components**: ${AFFECTED}

Use the OpenShift Troubleshooting Methodology to:
1. Investigate the reported symptom systematically
2. Gather evidence from logs, events, and configurations
3. Identify the root cause with supporting data
4. Provide actionable remediation steps

**Tools available**:
- omc (OpenShift Must-Gather Client)
- Standard Linux utilities
- Must-gather data structure

**Expected outcome**: Professional diagnostic report with root cause identification and specific remediation steps.

---

## Quick Start Commands

\`\`\`bash
# Navigate to must-gather directory
cd $(dirname "$MG_DIR")

# Initialize omc context
omc use $(basename "$MG_DIR")

# Quick cluster health check
omc get clusteroperators
omc get nodes
omc get pods -A | grep -vE 'Running|Completed'
omc get events -A | grep "${AFFECTED}"
\`\`\`

---

## Note on Express Mode

This prompt was generated in **express mode** with limited input detail.

For more comprehensive analysis with detailed context:
1. Use the full interactive mode: \`./ocp-diagnostic-helper.sh\`
2. Provide additional evidence (logs, outputs, timeline)
3. Include recent changes and observations

Express mode provides a solid starting point but may require follow-up questions from the AI to gather additional context.

EOF

print_success "Diagnostic prompt created: $OUTPUT_FILE"

# Create quick diagnostic script
SCRIPT_FILE="quick-diagnostic-express_${TIMESTAMP}.sh"

cat > "$SCRIPT_FILE" << EOFSCRIPT
#!/bin/bash
# Quick Diagnostic Script (Express Mode)
# Generated: $(date)

set -e

MG_DIR="$MG_DIR"
MG_SUBDIR="\$(basename "\$MG_DIR")"

cd "\$(dirname "\$MG_DIR")"
omc use "\$MG_SUBDIR"

echo "=== Cluster Operators ==="
omc get clusteroperators

echo -e "\n=== Nodes ==="
omc get nodes

echo -e "\n=== Degraded Operators ==="
omc get co | grep -v "True.*False.*False" || echo "None"

echo -e "\n=== Problematic Pods ==="
omc get pods -A | grep -vE 'Running|Completed|Success' | head -50

echo -e "\n=== Events: ${AFFECTED} ==="
omc get events -A | grep "${AFFECTED}" | head -30

echo -e "\n=== Complete ==="
EOFSCRIPT

chmod +x "$SCRIPT_FILE"
print_success "Quick diagnostic script: $SCRIPT_FILE"

# Summary
echo
echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════${NC}"
echo -e "${GREEN}${BOLD}  Express Mode Complete!${NC}"
echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════${NC}"
echo
echo -e "  📄 Prompt:  ${GREEN}$OUTPUT_FILE${NC}"
echo -e "  🚀 Script:  ${GREEN}$SCRIPT_FILE${NC}"
echo -e "  🎯 Focus:   ${YELLOW}$SYMPTOM${NC}"
echo -e "  📦 Target:  ${YELLOW}$AFFECTED${NC}"
echo
echo -e "${CYAN}Next steps:${NC}"
echo "  1. Review: less $OUTPUT_FILE"
echo "  2. Analyze: cat $OUTPUT_FILE | your-ai-tool"
echo "  3. Quick check: ./$SCRIPT_FILE"
echo

if [ "$VERBOSE" = true ]; then
    echo -e "${CYAN}Verbose output - File preview:${NC}"
    head -50 "$OUTPUT_FILE"
fi
