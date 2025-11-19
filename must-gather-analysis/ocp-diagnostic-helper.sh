#!/bin/bash

#####################################################################
# OpenShift Diagnostic Helper Script
# Purpose: Guide users through creating diagnostic prompts for AI
# Usage: ./ocp-diagnostic-helper.sh [must-gather-path]
#####################################################################

set -e

# Colors for better UX
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Output file
OUTPUT_FILE="diagnostic-prompt.md"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

#####################################################################
# Helper Functions
#####################################################################

print_header() {
    echo -e "\n${CYAN}${BOLD}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}${BOLD}  $1${NC}"
    echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════════════${NC}\n"
}

print_section() {
    echo -e "\n${BLUE}${BOLD}▶ $1${NC}"
    echo -e "${BLUE}────────────────────────────────────────────────────${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ Error: $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ Warning: $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ $1${NC}"
}

prompt_input() {
    local prompt_text="$1"
    local var_name="$2"
    local default_value="$3"

    if [ -n "$default_value" ]; then
        echo -e "${YELLOW}${prompt_text}${NC} ${CYAN}[default: ${default_value}]${NC}"
    else
        echo -e "${YELLOW}${prompt_text}${NC}"
    fi

    read -r input
    if [ -z "$input" ] && [ -n "$default_value" ]; then
        eval "$var_name='$default_value'"
    else
        eval "$var_name='$input'"
    fi
}

prompt_multiline() {
    local prompt_text="$1"
    local var_name="$2"

    echo -e "${YELLOW}${prompt_text}${NC}"
    echo -e "${CYAN}(Enter your text. Press Ctrl+D when done, or type 'END' on a new line)${NC}"

    local content=""
    while IFS= read -r line; do
        if [ "$line" = "END" ]; then
            break
        fi
        content="${content}${line}\n"
    done

    eval "$var_name='$content'"
}

prompt_yes_no() {
    local prompt_text="$1"
    local default="$2"

    if [ "$default" = "y" ]; then
        echo -e "${YELLOW}${prompt_text} [Y/n]${NC}"
    else
        echo -e "${YELLOW}${prompt_text} [y/N]${NC}"
    fi

    read -r response
    response=${response:-$default}

    if [[ "$response" =~ ^[Yy]$ ]]; then
        return 0
    else
        return 1
    fi
}

#####################################################################
# Must-Gather Detection and Validation
#####################################################################

detect_must_gather() {
    local base_path="$1"

    print_section "Detecting Must-Gather Structure"

    if [ -z "$base_path" ]; then
        print_error "No must-gather path provided"
        return 1
    fi

    if [ ! -d "$base_path" ]; then
        print_error "Directory does not exist: $base_path"
        return 1
    fi

    # Find the actual must-gather data directory (usually starts with quay-io or similar)
    local mg_dir=$(find "$base_path" -maxdepth 1 -type d -name "quay-io*" -o -name "registry*" | head -1)

    if [ -z "$mg_dir" ]; then
        print_warning "Could not auto-detect must-gather subdirectory"
        print_info "Available directories:"
        ls -1 "$base_path" | grep -v "^event-filter" | grep -v "^timestamp"
        echo
        prompt_input "Enter the must-gather subdirectory name:" mg_subdir
        mg_dir="$base_path/$mg_subdir"
    fi

    if [ ! -d "$mg_dir" ]; then
        print_error "Invalid must-gather directory: $mg_dir"
        return 1
    fi

    # Validate structure
    if [ ! -d "$mg_dir/namespaces" ] && [ ! -d "$mg_dir/cluster-scoped-resources" ]; then
        print_error "This doesn't appear to be a valid must-gather directory"
        return 1
    fi

    print_success "Must-gather directory detected: $mg_dir"

    # Try to get version
    if [ -f "$mg_dir/version" ]; then
        local version=$(cat "$mg_dir/version")
        print_info "Detected version: $version"
    fi

    echo "$mg_dir"
    return 0
}

check_omc() {
    print_section "Checking OMC Tool Availability"

    if command -v omc &> /dev/null; then
        local omc_version=$(omc version 2>/dev/null || echo "unknown")
        print_success "OMC tool found: $omc_version"
        return 0
    else
        print_warning "OMC tool not found in PATH"
        print_info "Install from: https://github.com/gmeghnag/omc"
        return 1
    fi
}

#####################################################################
# Quick Analysis Functions
#####################################################################

quick_analysis() {
    local mg_dir="$1"

    print_section "Quick Cluster Analysis (Optional)"

    if ! prompt_yes_no "Would you like to run a quick analysis to help fill the template?" "y"; then
        return
    fi

    if ! command -v omc &> /dev/null; then
        print_warning "OMC not available, skipping quick analysis"
        return
    fi

    print_info "Initializing OMC context..."
    local mg_subdir=$(basename "$mg_dir")

    # Change to parent directory and run omc use
    pushd "$(dirname "$mg_dir")" > /dev/null
    omc use "$mg_subdir" > /dev/null 2>&1 || {
        print_error "Failed to initialize OMC context"
        popd > /dev/null
        return
    }
    popd > /dev/null

    print_success "OMC context initialized"

    echo -e "\n${CYAN}Gathering cluster information...${NC}\n"

    # Cluster operators
    echo -e "${BOLD}Degraded Cluster Operators:${NC}"
    omc get co 2>/dev/null | grep -v "True.*False.*False" || echo "  None found"

    echo -e "\n${BOLD}Non-Ready Nodes:${NC}"
    omc get nodes 2>/dev/null | grep -v "Ready" | tail -n +2 || echo "  None found"

    echo -e "\n${BOLD}Problematic Pods (non-Running/Completed):${NC}"
    omc get pods -A 2>/dev/null | grep -vE "Running|Completed|Success" | tail -n +2 | head -20 || echo "  None found"

    echo -e "\n${BOLD}Recent Events (Warning/Error):${NC}"
    omc get events -A 2>/dev/null | grep -E "Warning|Error" | head -10 || echo "  None found"

    echo -e "\n${GREEN}${BOLD}Quick analysis complete! Use this information to fill the template.${NC}\n"
}

#####################################################################
# Template Generation
#####################################################################

generate_prompt() {
    local mg_dir="$1"

    print_header "OpenShift Diagnostic Prompt Generator"

    # Introduction
    cat << 'EOF'
This interactive script will help you create a comprehensive diagnostic
prompt for AI analysis of your OpenShift cluster issues.

You'll be guided through each section step by step.
EOF

    echo
    read -p "Press Enter to begin..."

    #####################################################################
    # Section 1: Problem Context
    #####################################################################

    print_header "Section 1: Problem Context"

    print_section "1.1 Primary Symptom"
    prompt_input "What is the primary symptom/issue? (e.g., pods in CrashLoopBackOff)" PRIMARY_SYMPTOM

    print_section "1.2 Affected Components"
    prompt_input "What components are affected? (e.g., namespace/pods/operators)" AFFECTED_COMPONENTS

    print_section "1.3 Observable Evidence"
    echo -e "${CYAN}Paste any relevant command outputs, logs, or error messages.${NC}"
    echo -e "${CYAN}This helps provide context. Examples:${NC}"
    echo -e "  - oc get pods output showing the issue"
    echo -e "  - Error messages from logs"
    echo -e "  - Alert descriptions"
    echo
    prompt_multiline "Enter observable evidence:" OBSERVABLE_EVIDENCE

    print_section "1.4 Timeline (Optional)"
    prompt_input "When did the issue start? (e.g., '3 days ago', '2025-11-15', 'unknown')" TIMELINE "unknown"
    prompt_input "How frequently does it occur? (e.g., 'constant', 'intermittent', 'once')" FREQUENCY "constant"

    print_section "1.5 Initial Observations (Optional)"
    if prompt_yes_no "Do you have any initial observations or patterns?" "n"; then
        prompt_multiline "Enter your observations (one per line):" OBSERVATIONS
    else
        OBSERVATIONS=""
    fi

    print_section "1.6 Tentative Diagnosis (Optional)"
    if prompt_yes_no "Do you have a suspected root cause?" "n"; then
        prompt_input "What is your suspected root cause?" SUSPECTED_CAUSE
        prompt_input "What evidence supports this hypothesis?" SUPPORTING_EVIDENCE
    else
        SUSPECTED_CAUSE=""
        SUPPORTING_EVIDENCE=""
    fi

    #####################################################################
    # Section 2: Environment Information
    #####################################################################

    print_header "Section 2: Environment Information"

    print_section "2.1 Must-Gather Details"
    echo -e "${GREEN}Must-Gather Path: $mg_dir${NC}"

    # Try to detect version
    OCP_VERSION="unknown"
    if [ -f "$mg_dir/version" ]; then
        OCP_VERSION=$(head -1 "$mg_dir/version")
        print_info "Auto-detected version: $OCP_VERSION"
    fi
    prompt_input "OpenShift version (if different):" OCP_VERSION_INPUT "$OCP_VERSION"
    [ -n "$OCP_VERSION_INPUT" ] && OCP_VERSION="$OCP_VERSION_INPUT"

    # Collection date
    COLLECTION_DATE="unknown"
    if [ -f "$mg_dir/timestamp" ]; then
        COLLECTION_DATE=$(cat "$mg_dir/timestamp" | head -1)
    fi
    prompt_input "Must-gather collection date:" COLLECTION_DATE_INPUT "$COLLECTION_DATE"
    [ -n "$COLLECTION_DATE_INPUT" ] && COLLECTION_DATE="$COLLECTION_DATE_INPUT"

    #####################################################################
    # Section 3: Analysis Focus
    #####################################################################

    print_header "Section 3: Analysis Focus"

    print_section "3.1 Primary Analysis Area"
    echo "Select the primary area to focus the analysis:"
    echo "  1) Application/Pod issues"
    echo "  2) Network/Connectivity"
    echo "  3) Storage/PV/PVC"
    echo "  4) Cluster Operators"
    echo "  5) Node/Infrastructure"
    echo "  6) Performance/Resource"
    echo "  7) Security/RBAC"
    echo "  8) Comprehensive (all areas)"

    read -p "Enter choice [1-8]: " FOCUS_CHOICE
    case $FOCUS_CHOICE in
        1) FOCUS_AREA="Application/Pod issues";;
        2) FOCUS_AREA="Network/Connectivity";;
        3) FOCUS_AREA="Storage/PV/PVC";;
        4) FOCUS_AREA="Cluster Operators";;
        5) FOCUS_AREA="Node/Infrastructure";;
        6) FOCUS_AREA="Performance/Resource";;
        7) FOCUS_AREA="Security/RBAC";;
        8) FOCUS_AREA="Comprehensive (all areas)";;
        *) FOCUS_AREA="Comprehensive (all areas)";;
    esac
    print_success "Focus area: $FOCUS_AREA"

    print_section "3.2 Specific Components to Investigate"
    if prompt_yes_no "Do you want to specify particular components to investigate?" "y"; then
        prompt_input "Namespace(s) to focus on (comma-separated, or 'all'):" FOCUS_NAMESPACES "all"
        prompt_input "Pod name pattern (if applicable, or 'none'):" FOCUS_PODS "none"
        prompt_input "Node name pattern (if applicable, or 'none'):" FOCUS_NODES "none"
    else
        FOCUS_NAMESPACES="all"
        FOCUS_PODS="none"
        FOCUS_NODES="none"
    fi

    #####################################################################
    # Section 4: Additional Context
    #####################################################################

    print_header "Section 4: Additional Context"

    print_section "4.1 Recent Changes"
    if prompt_yes_no "Have there been recent changes (upgrades, config changes, etc.)?" "n"; then
        prompt_multiline "Describe recent changes:" RECENT_CHANGES
    else
        RECENT_CHANGES="None reported"
    fi

    print_section "4.2 Business Impact"
    prompt_input "What is the business impact? (Low/Medium/High/Critical)" BUSINESS_IMPACT "Medium"

    print_section "4.3 Additional Notes"
    if prompt_yes_no "Any additional context or notes?" "n"; then
        prompt_multiline "Enter additional notes:" ADDITIONAL_NOTES
    else
        ADDITIONAL_NOTES=""
    fi

    #####################################################################
    # Generate the Complete Prompt
    #####################################################################

    print_header "Generating Diagnostic Prompt"

    local output_file="${OUTPUT_FILE/.md/_${TIMESTAMP}.md}"

    cat > "$output_file" << EOF
# OpenShift Cluster Diagnostic Analysis Request

**Generated**: $(date)
**Must-Gather**: $(basename "$mg_dir")

---

## Problem Context

### Symptom Description

**Primary symptom**: ${PRIMARY_SYMPTOM}

**Affected components**: ${AFFECTED_COMPONENTS}

**Timeline**:
- Started: ${TIMELINE}
- Frequency: ${FREQUENCY}

**Observable evidence**:
\`\`\`
$(echo -e "$OBSERVABLE_EVIDENCE")
\`\`\`

EOF

    if [ -n "$OBSERVATIONS" ]; then
        cat >> "$output_file" << EOF
### Initial Observations
$(echo -e "$OBSERVATIONS")

EOF
    fi

    if [ -n "$SUSPECTED_CAUSE" ]; then
        cat >> "$output_file" << EOF
### Tentative Diagnosis
- **Suspected root cause**: ${SUSPECTED_CAUSE}
- **Supporting evidence**: ${SUPPORTING_EVIDENCE}

EOF
    fi

    cat >> "$output_file" << EOF
---

## Environment Information

### Must-Gather Location
- **Path**: \`$mg_dir\`
- **Collection date**: ${COLLECTION_DATE}
- **OpenShift version**: ${OCP_VERSION}

### Tool Requirements
Use the following tools for cluster analysis:
- **omc (OpenShift Must-Gather Client)**: For querying must-gather data
  - Initialize with: \`omc use $(basename "$mg_dir")\`
  - Working directory: \`$(dirname "$mg_dir")\`

---

## Analysis Requirements

### Primary Focus Area
${FOCUS_AREA}

### Specific Components
- **Namespaces**: ${FOCUS_NAMESPACES}
- **Pods**: ${FOCUS_PODS}
- **Nodes**: ${FOCUS_NODES}

### Recent Changes
${RECENT_CHANGES}

### Business Impact
${BUSINESS_IMPACT}

EOF

    if [ -n "$ADDITIONAL_NOTES" ]; then
        cat >> "$output_file" << EOF
### Additional Context
$(echo -e "$ADDITIONAL_NOTES")

EOF
    fi

    cat >> "$output_file" << 'EOF'
---

## Analysis Framework

Follow the **OpenShift Troubleshooting Methodology**:

### 1. Start with the Phenomenon
- Begin with the specific alert, error, or observed issue
- Document the exact symptoms and scope

### 2. Utilize Tools
- Use must-gather to collect the global state ("big picture")
- Leverage omc for efficient data querying

### 3. Logical Reasoning

#### Top-Down Approach
Follow the application stack downward:
1. **Application Layer** → Check pod status, logs, configurations
2. **Network Layer** → Verify service connectivity, DNS, routing
3. **Storage Layer** → Check PV/PVC status, storage operators
4. **Scheduling Layer** → Validate pod placement, resource availability
5. **Control Plane** → Review cluster operators, API server health

#### Bottom-Up Approach
When infrastructure issues are suspected:
1. **Operating System** → Check node conditions, kernel logs
2. **Node Resources** → CPU, memory, disk, PID pressure
3. **Container Runtime** → CRI-O/containerd health
4. **Kubelet** → Node agent logs and status
5. **Pod Layer** → Container status and application logs

#### Iterative Cycle
- Move between "point" (specific issue) and "big picture" (cluster state)
- Gradually narrow the scope through hypothesis testing
- Form and validate hypotheses based on collected data

### 4. Identify Root Cause
- Pinpoint a specific, actionable root cause
- Distinguish between symptoms and underlying issues
- Validate with supporting evidence from multiple sources

---

## Required Analysis Tasks

### Task Checklist
Perform the following diagnostic steps:

- [ ] **Cluster Health Overview**
  - Check cluster operator status: `omc get clusteroperators`
  - Check cluster version and upgrade history
  - Review node status: `omc get nodes`

- [ ] **Component-Specific Analysis**
  - Examine affected namespace/pods: `omc get pods -n <namespace>`
  - Review pod descriptions and events: `omc describe pod <pod-name> -n <namespace>`
  - Analyze pod logs: `omc logs pod/<pod-name> -n <namespace> -c <container>`
  - Check resource configurations (DaemonSets, Deployments, StatefulSets)

- [ ] **Event Analysis**
  - Review cluster events for patterns
  - Identify event frequency and timing
  - Correlate events across components

- [ ] **Resource Analysis**
  - Check node resource allocation and pressure
  - Review pod resource requests/limits
  - Identify resource bottlenecks

- [ ] **Configuration Review**
  - Examine relevant CRDs and configurations
  - Check for recent changes or updates
  - Validate probe configurations (liveness, readiness, startup)

- [ ] **Pattern Recognition**
  - Identify affected vs. healthy instances
  - Determine commonalities among failures
  - Assess temporal patterns (time-based failures)

---

## Deliverable: Comprehensive Diagnostic Report

Generate a detailed feasibility report with the following structure:

### 1. Executive Summary
- Brief overview of the issue
- Root cause in 1-2 sentences
- Impact severity assessment

### 2. Cluster Information
- Platform (AWS/Azure/GCP/vSphere/Bare Metal)
- OpenShift version
- Cluster topology (node count, roles)
- Overall health status

### 3. Problem Statement
- Detailed symptom description
- Affected components with specifics
- Timeline (when did it start, frequency)
- Current state vs. expected state

### 4. Investigation Findings
- **Cluster Health**: Operator status, node health
- **Component Analysis**: Detailed examination of affected resources
- **Event Correlation**: Patterns from events
- **Resource Metrics**: CPU, memory, storage, network observations
- **Configuration Issues**: Misconfigurations or suboptimal settings

### 5. Root Cause Analysis
- **Primary cause**: The fundamental issue
- **Contributing factors**: Secondary issues that exacerbate the problem
- **Evidence**: Supporting data from logs, events, configurations
- **Methodology**: How the diagnosis was reached

### 6. Impact Assessment
- **Functional impact**: What capabilities are affected
- **Operational impact**: Resource waste, noise, performance degradation
- **Risk assessment**: Potential for escalation or spread

### 7. Recommended Solution
- **Immediate mitigation**: Quick fixes to stabilize
- **Permanent resolution**: Long-term fix
- **Implementation steps**: Specific commands or procedures
- **Testing validation**: How to verify the fix

### 8. Validation Steps
- Post-fix monitoring procedures
- Success criteria
- Rollback plan if needed

### 9. Additional Observations
- Related findings
- Potential future issues
- Recommendations for prevention

---

## Analysis Guidelines

### Best Practices
1. **Use omc context**: Always run `omc use <directory>` before querying
2. **Parallel investigation**: Use multiple data sources simultaneously
3. **Evidence-based**: Every conclusion must be supported by data
4. **Correlation over causation**: Distinguish between related events and root causes
5. **Completeness**: Check all instances, not just the first failure

### Common Pitfalls to Avoid
- Don't assume the first error is the root cause
- Don't ignore healthy instances (they provide contrast)
- Don't overlook event counts (frequency indicates severity)
- Don't stop at symptoms (dig deeper for underlying issues)
- Don't make recommendations without validation data

---

## Task Execution Instructions

**Instruction to AI**:

Using the must-gather snapshot in the specified directory and the omc tool, perform a complete diagnostic analysis following the OpenShift Troubleshooting Methodology.

Investigate the reported symptoms, identify the root cause through systematic analysis, and generate a comprehensive diagnostic report as specified above.

**Tools available**:
- omc (OpenShift Must-Gather Client)
- Standard Linux utilities for file analysis
- Must-gather data structure

**Expected outcome**: A professional, actionable diagnostic report that clearly identifies the root cause and provides specific remediation steps.

---

## Quick Start Commands

Initialize your analysis session:

\`\`\`bash
# Navigate to must-gather directory
cd $(dirname "$mg_dir")

# Initialize omc context
omc use $(basename "$mg_dir")

# Quick cluster health check
omc get clusteroperators
omc get nodes
omc get pods -A | grep -vE 'Running|Completed'
\`\`\`

EOF

    print_success "Prompt generated: $output_file"

    # Summary
    print_header "Summary"
    echo -e "${CYAN}Diagnostic prompt has been created successfully!${NC}\n"
    echo -e "  📄 File: ${GREEN}${BOLD}$output_file${NC}"
    echo -e "  📁 Size: $(wc -l < "$output_file") lines"
    echo -e "  🎯 Focus: $FOCUS_AREA"
    echo

    # Next steps
    print_section "Next Steps"
    echo "1. Review the generated prompt: less $output_file"
    echo "2. Copy the prompt to your AI assistant (Claude Code, ChatGPT, etc.)"
    echo "3. Or use it with this must-gather: cat $output_file | pbcopy"
    echo

    # Offer to display
    if prompt_yes_no "Would you like to view the prompt now?" "y"; then
        less "$output_file"
    fi

    # Offer to create a helper script
    if prompt_yes_no "Create a quick diagnostic script to run key commands?" "y"; then
        create_diagnostic_script "$mg_dir" "$output_file"
    fi
}

#####################################################################
# Create Quick Diagnostic Script
#####################################################################

create_diagnostic_script() {
    local mg_dir="$1"
    local prompt_file="$2"

    local script_file="quick-diagnostic_${TIMESTAMP}.sh"

    cat > "$script_file" << EOF
#!/bin/bash
#
# Quick Diagnostic Script
# Generated: $(date)
# Must-Gather: $mg_dir
#

set -e

MG_DIR="$mg_dir"
MG_SUBDIR="\$(basename "\$MG_DIR")"

echo "========================================="
echo "OpenShift Quick Diagnostic"
echo "========================================="
echo

cd "\$(dirname "\$MG_DIR")"

echo "Initializing OMC context..."
omc use "\$MG_SUBDIR"

echo
echo "========================================="
echo "Cluster Operators"
echo "========================================="
omc get clusteroperators

echo
echo "========================================="
echo "Nodes"
echo "========================================="
omc get nodes

echo
echo "========================================="
echo "Degraded Operators"
echo "========================================="
omc get co | grep -v "True.*False.*False" || echo "None found"

echo
echo "========================================="
echo "Problematic Pods (Top 50)"
echo "========================================="
omc get pods -A | grep -vE 'Running|Completed|Success' | head -50 || echo "None found"

echo
echo "========================================="
echo "Recent Warning/Error Events (Top 30)"
echo "========================================="
omc get events -A | grep -E 'Warning|Error' | head -30 || echo "None found"

echo
echo "========================================="
echo "Cluster Version"
echo "========================================="
cat "\$MG_DIR/version" 2>/dev/null || echo "Not found"

echo
echo "========================================="
echo "Diagnostic Complete"
echo "========================================="
echo
echo "For full AI analysis, use: $prompt_file"
EOF

    chmod +x "$script_file"
    print_success "Quick diagnostic script created: $script_file"
    echo -e "  Run it with: ${GREEN}./$script_file${NC}"
}

#####################################################################
# Main Execution
#####################################################################

main() {
    clear

    print_header "OpenShift Diagnostic Helper"

    cat << 'EOF'
    ___  __________    ____  _                             __  _
   / _ \/ ___/ __ \  / __ \(_)___ _____ _____  ____  _____/ /_(_)____
  / // / /__/ /_/ / / / / / / __ `/ __ `/ __ \/ __ \/ ___/ __/ / ___/
 / // / /__/ ____/ / /_/ / / /_/ / /_/ / / / / /_/ (__  ) /_/ / /__
/_____\___/_/     /_____/_/\__,_/\__, /_/ /_/\____/____/\__/_/\___/
                                /____/
EOF

    echo -e "\n${CYAN}This tool helps you create comprehensive diagnostic prompts for AI analysis${NC}\n"

    # Check for must-gather path
    MG_BASE_PATH="${1:-}"

    if [ -z "$MG_BASE_PATH" ]; then
        prompt_input "Enter the must-gather base directory path:" MG_BASE_PATH "$(pwd)"
    fi

    # Detect and validate must-gather
    MG_DIR=$(detect_must_gather "$MG_BASE_PATH")
    if [ $? -ne 0 ]; then
        print_error "Failed to detect valid must-gather directory"
        exit 1
    fi

    # Check OMC
    check_omc

    # Optional quick analysis
    quick_analysis "$MG_DIR"

    # Generate the prompt
    generate_prompt "$MG_DIR"

    print_header "Thank You!"
    echo -e "${GREEN}${BOLD}Diagnostic prompt generation complete!${NC}\n"
    echo -e "For questions or issues, consult the OpenShift documentation:"
    echo -e "  https://docs.openshift.com/\n"
}

# Run main function
main "$@"
