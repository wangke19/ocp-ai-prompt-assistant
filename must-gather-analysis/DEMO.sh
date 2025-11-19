#!/bin/bash

#####################################################################
# Demo Script - OpenShift Diagnostic Helper
# This demonstrates both express and interactive modes
#####################################################################

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'
BOLD='\033[1m'

clear

cat << 'EOF'
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║     OpenShift Diagnostic Helper - Interactive Demo            ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝

This demo will show you how to use both modes of the diagnostic helper.

EOF

echo -e "${CYAN}Press Enter to continue...${NC}"
read

#####################################################################
# Demo 1: Express Mode
#####################################################################

clear
echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${CYAN}  Demo 1: Express Mode (Quick Diagnosis)${NC}"
echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════${NC}\n"

cat << 'EOF'
Express mode is the fastest way to generate a diagnostic prompt.
You just need 3 pieces of information:

  1. Must-gather path
  2. Symptom description
  3. Affected component

Example command:
EOF

cat << 'EXAMPLE'
./ocp-diagnostic-express.sh \
  must-gather.local.2983011968230520427/ \
  "insights-runtime-extractor pods in CrashLoopBackOff with liveness probe timeouts" \
  "openshift-insights namespace"
EXAMPLE

echo -e "\n${YELLOW}Would you like to run this demo now? [y/N]${NC}"
read -r response

if [[ "$response" =~ ^[Yy]$ ]]; then
    echo -e "\n${GREEN}Running express mode demo...${NC}\n"

    ./ocp-diagnostic-express.sh \
        must-gather.local.2983011968230520427/ \
        "insights-runtime-extractor pods in CrashLoopBackOff with liveness probe timeouts" \
        "openshift-insights namespace" \
        -o demo-express-output.md

    echo -e "\n${GREEN}✓ Express mode complete!${NC}"
    echo -e "  Generated file: ${CYAN}demo-express-output_*.md${NC}\n"

    echo -e "${YELLOW}View the generated prompt? [y/N]${NC}"
    read -r view_response
    if [[ "$view_response" =~ ^[Yy]$ ]]; then
        echo -e "\n${CYAN}First 50 lines of generated prompt:${NC}\n"
        head -50 demo-express-output_*.md
        echo -e "\n${CYAN}...${NC}"
        echo -e "\n${YELLOW}Press Enter to continue...${NC}"
        read
    fi
else
    echo -e "${CYAN}Skipping express mode demo${NC}"
fi

#####################################################################
# Demo 2: Interactive Mode Preview
#####################################################################

clear
echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${CYAN}  Demo 2: Interactive Mode (Detailed Diagnosis)${NC}"
echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════${NC}\n"

cat << 'EOF'
Interactive mode guides you step-by-step through creating a
comprehensive diagnostic prompt.

It collects:
  • Detailed symptom description
  • Observable evidence (logs, outputs)
  • Timeline and frequency
  • Initial observations
  • Recent changes
  • Business impact
  • Focus areas

The process takes 5-10 minutes but produces a much more detailed
prompt for AI analysis.

Example command:
EOF

cat << 'EXAMPLE'
./ocp-diagnostic-helper.sh must-gather.local.2983011968230520427/
EXAMPLE

echo -e "\n${YELLOW}Would you like to see a preview of the interactive flow? [y/N]${NC}"
read -r response

if [[ "$response" =~ ^[Yy]$ ]]; then
    cat << 'PREVIEW'

Interactive Flow Preview:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Section 1: Problem Context
  ├─ Primary symptom: [What's the issue?]
  ├─ Affected components: [What's broken?]
  ├─ Observable evidence: [Paste outputs/logs]
  ├─ Timeline: [When did it start?]
  ├─ Frequency: [How often?]
  ├─ Initial observations: [What have you noticed?]
  └─ Tentative diagnosis: [Your hypothesis?]

Section 2: Environment Information
  ├─ Must-gather path: [Auto-detected]
  ├─ OCP version: [Auto-detected]
  └─ Collection date: [Auto-detected]

Section 3: Analysis Focus
  ├─ Primary area:
  │   1) Application/Pod
  │   2) Network
  │   3) Storage
  │   4) Operators
  │   5) Node/Infra
  │   6) Performance
  │   7) Security
  │   8) Comprehensive
  ├─ Focus namespaces: [Which namespaces?]
  ├─ Focus pods: [Which pods?]
  └─ Focus nodes: [Which nodes?]

Section 4: Additional Context
  ├─ Recent changes: [Upgrades, config changes?]
  ├─ Business impact: [Low/Medium/High/Critical]
  └─ Additional notes: [Anything else?]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

PREVIEW

    echo -e "\n${YELLOW}Run interactive mode now? [y/N]${NC}"
    echo -e "${CYAN}(This will be a real interactive session)${NC}"
    read -r run_response

    if [[ "$run_response" =~ ^[Yy]$ ]]; then
        echo -e "\n${GREEN}Launching interactive mode...${NC}\n"
        ./ocp-diagnostic-helper.sh must-gather.local.2983011968230520427/
    else
        echo -e "${CYAN}Skipping interactive mode demo${NC}"
    fi
else
    echo -e "${CYAN}Skipping interactive mode preview${NC}"
fi

#####################################################################
# Demo 3: Using OMC
#####################################################################

clear
echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${CYAN}  Demo 3: Quick Analysis with OMC${NC}"
echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════${NC}\n"

cat << 'EOF'
The scripts can use OMC (OpenShift Must-Gather Client) to perform
quick analysis of your cluster.

This helps you gather context before creating the diagnostic prompt.

EOF

if ! command -v omc &> /dev/null; then
    echo -e "${YELLOW}⚠ OMC not found on your system${NC}"
    echo -e "  Install from: ${CYAN}https://github.com/gmeghnag/omc${NC}\n"
    echo -e "  The scripts will work without it, but quick analysis won't be available.\n"
else
    echo -e "${GREEN}✓ OMC is installed!${NC}\n"

    echo -e "${YELLOW}Run quick analysis now? [y/N]${NC}"
    read -r response

    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo -e "\n${GREEN}Running quick analysis...${NC}\n"

        cd must-gather.local.2983011968230520427/
        MG_SUBDIR=$(basename quay-io-*)

        omc use "$MG_SUBDIR"

        echo -e "${CYAN}Cluster Operators:${NC}"
        omc get clusteroperators | head -10

        echo -e "\n${CYAN}Nodes:${NC}"
        omc get nodes

        echo -e "\n${CYAN}Problematic Pods:${NC}"
        omc get pods -A | grep -vE 'Running|Completed|Success' | head -10

        echo -e "\n${GREEN}✓ Quick analysis complete${NC}"

        cd ..
    else
        echo -e "${CYAN}Skipping quick analysis demo${NC}"
    fi
fi

echo -e "\n${YELLOW}Press Enter to continue...${NC}"
read

#####################################################################
# Summary
#####################################################################

clear
echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${CYAN}  Demo Complete - Summary${NC}"
echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════${NC}\n"

cat << 'EOF'
You now know how to use the OpenShift Diagnostic Helper!

Quick Reference:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📦 Express Mode (30 seconds)
   ./ocp-diagnostic-express.sh <path> "<symptom>" "<component>"

📋 Interactive Mode (5-10 minutes)
   ./ocp-diagnostic-helper.sh [path]

🔍 Quick Health Check
   ./quick-diagnostic_*.sh

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

What to do with generated prompts:

1. Review the prompt file
   less diagnostic-prompt_*.md

2. Copy to AI assistant
   - Claude Code: Read the file or paste content
   - ChatGPT: Copy and paste
   - Local LLM: Pipe to your model

3. Get comprehensive analysis
   The AI will analyze and provide:
   • Root cause identification
   • Impact assessment
   • Remediation steps
   • Validation procedures

4. Apply fixes and validate

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Example Real-World Workflow:

$ # Collect must-gather
$ oc adm must-gather

$ # Generate diagnostic prompt
$ ./ocp-diagnostic-express.sh \
    must-gather.local.*/ \
    "Your symptom here" \
    "Affected component"

$ # Copy to Claude Code
$ cat diagnostic-prompt_*.md

$ # Paste in Claude Code and get analysis

$ # Apply recommended fix

$ # Validate with quick diagnostic
$ ./quick-diagnostic_*.sh

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

For more information:
• README: less README-diagnostic-helper.md
• Quick Start: less QUICKSTART.md

EOF

echo -e "${GREEN}${BOLD}Happy troubleshooting! 🔧${NC}\n"

# Cleanup demo files
if [ -f demo-express-output_*.md ]; then
    echo -e "${YELLOW}Demo generated these files:${NC}"
    ls -lh demo-express-output_* quick-diagnostic-express_* 2>/dev/null
    echo
    echo -e "${YELLOW}Remove demo files? [y/N]${NC}"
    read -r cleanup
    if [[ "$cleanup" =~ ^[Yy]$ ]]; then
        rm -f demo-express-output_* quick-diagnostic-express_*
        echo -e "${GREEN}✓ Demo files cleaned up${NC}"
    fi
fi

echo
