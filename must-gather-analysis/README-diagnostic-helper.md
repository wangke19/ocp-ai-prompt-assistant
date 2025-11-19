# OpenShift Diagnostic Helper

An interactive script to help create comprehensive diagnostic prompts for AI-assisted OpenShift troubleshooting.

## Features

- 🔍 **Auto-detection** of must-gather directory structure
- 📊 **Quick analysis** using omc to gather cluster insights
- 📝 **Step-by-step guidance** through creating diagnostic prompts
- 🎯 **Customizable focus** areas for targeted analysis
- 🤖 **AI-ready output** formatted for Claude Code, ChatGPT, or other AI assistants
- 🚀 **Quick diagnostic scripts** for rapid cluster health checks

## Prerequisites

### Required
- Bash shell (Linux/macOS)
- Must-gather data from an OpenShift cluster

### Optional (but recommended)
- [omc (OpenShift Must-Gather Client)](https://github.com/gmeghnag/omc)
  - Enables quick analysis and cluster insights
  - Installation: Download from releases or build from source

## Installation

1. Download the script:
```bash
curl -O https://path-to-script/ocp-diagnostic-helper.sh
chmod +x ocp-diagnostic-helper.sh
```

Or simply make the existing script executable:
```bash
chmod +x ocp-diagnostic-helper.sh
```

## Usage

### Basic Usage

```bash
./ocp-diagnostic-helper.sh
```

The script will prompt you for the must-gather directory location.

### With Must-Gather Path

```bash
./ocp-diagnostic-helper.sh /path/to/must-gather
```

### Interactive Workflow

The script guides you through 4 main sections:

#### 1️⃣ Problem Context
- Primary symptom description
- Affected components
- Observable evidence
- Timeline and frequency
- Initial observations (optional)
- Tentative diagnosis (optional)

#### 2️⃣ Environment Information
- Must-gather location (auto-detected)
- OpenShift version (auto-detected if available)
- Collection date

#### 3️⃣ Analysis Focus
- Primary analysis area selection
- Specific components to investigate
- Namespace/pod/node filtering

#### 4️⃣ Additional Context
- Recent changes
- Business impact
- Additional notes

### Quick Analysis Feature

If `omc` is available, the script can perform a quick analysis to help you identify:
- Degraded cluster operators
- Non-ready nodes
- Problematic pods
- Recent warning/error events

This information helps you fill out the diagnostic prompt more accurately.

## Output Files

The script generates:

1. **Diagnostic Prompt** (`diagnostic-prompt_YYYYMMDD_HHMMSS.md`)
   - Complete, AI-ready diagnostic request
   - Includes all context and requirements
   - Formatted for direct use with AI assistants

2. **Quick Diagnostic Script** (optional, `quick-diagnostic_YYYYMMDD_HHMMSS.sh`)
   - Executable script for rapid cluster health checks
   - Runs key omc commands
   - Generates summary report

## Example Session

```bash
$ ./ocp-diagnostic-helper.sh must-gather.local.123456789/

═══════════════════════════════════════════════════════════════
  OpenShift Diagnostic Helper
═══════════════════════════════════════════════════════════════

This tool helps you create comprehensive diagnostic prompts for AI analysis

▶ Detecting Must-Gather Structure
────────────────────────────────────────────────────
✓ Must-gather directory detected: must-gather.local.123456789/quay-io-...
ℹ Detected version: 4.19.12

▶ Checking OMC Tool Availability
────────────────────────────────────────────────────
✓ OMC tool found: v1.2.3

▶ Quick Cluster Analysis (Optional)
────────────────────────────────────────────────────
Would you like to run a quick analysis to help fill the template? [Y/n] y

Gathering cluster information...

Degraded Cluster Operators:
  None found

Non-Ready Nodes:
  None found

Problematic Pods (non-Running/Completed):
openshift-insights   insights-runtime-extractor-pfwzt   2/3   CrashLoopBackOff

...
```

## Tips and Best Practices

### 1. Prepare Information in Advance

Before running the script, gather:
- Command outputs showing the issue (`oc get pods`, etc.)
- Relevant error messages from logs
- Timeline of when the issue started
- Any recent changes made to the cluster

### 2. Use Quick Analysis

The quick analysis feature (requires omc) can help you:
- Identify issues you might have missed
- Get accurate pod/node names
- Understand the cluster state before filling the prompt

### 3. Be Specific in Evidence

When providing observable evidence:
- Include full command outputs, not summaries
- Add timestamps if available
- Include multiple examples if the issue is intermittent

### 4. Focus Areas

Choose the focus area that best matches your issue:
- **Application/Pod**: CrashLoopBackOff, ImagePullBackOff, container issues
- **Network/Connectivity**: Service access, DNS, routing problems
- **Storage**: PV/PVC issues, storage provisioning
- **Cluster Operators**: Degraded or unavailable operators
- **Node/Infrastructure**: Node NotReady, resource exhaustion
- **Performance**: Slow responses, high resource usage
- **Security/RBAC**: Authentication, authorization issues
- **Comprehensive**: Multiple issues or unknown root cause

### 5. Multi-line Input

When the script asks for multi-line input (evidence, observations):
- Paste your content
- Type `END` on a new line, OR
- Press `Ctrl+D` to finish

### 6. Review Before Submitting

Always review the generated prompt file before sending to AI:
```bash
less diagnostic-prompt_YYYYMMDD_HHMMSS.md
```

## Advanced Usage

### Non-Interactive Mode (Future Enhancement)

For automation, you can create a config file:

```bash
# diagnostic-config.env
PRIMARY_SYMPTOM="Pods in CrashLoopBackOff"
AFFECTED_COMPONENTS="openshift-insights namespace"
FOCUS_AREA="Application/Pod issues"
# ... more variables
```

Then run:
```bash
./ocp-diagnostic-helper.sh --config diagnostic-config.env
```

*(Note: This feature is planned for future versions)*

### Batch Processing

To analyze multiple must-gather snapshots:

```bash
for mg in must-gather-*/; do
    ./ocp-diagnostic-helper.sh "$mg" < input-responses.txt
done
```

## Troubleshooting

### "OMC not found" warning

**Solution**: Install omc from https://github.com/gmeghnag/omc or continue without it (quick analysis will be skipped)

### "Failed to detect valid must-gather directory"

**Causes**:
- Incorrect path provided
- Must-gather is incomplete or corrupted
- Missing required subdirectories

**Solution**:
- Verify the path: `ls /path/to/must-gather`
- Ensure subdirectories exist: `cluster-scoped-resources/`, `namespaces/`
- Re-run `oc adm must-gather` if needed

### "Directory does not exist"

**Solution**: Provide the full absolute path or run from the parent directory

### Script hangs waiting for input

**Solution**:
- For multi-line input, type `END` or press `Ctrl+D`
- Press `Ctrl+C` to cancel and restart

## Using Generated Prompts with AI

### Claude Code

```bash
# Copy prompt to clipboard (macOS)
cat diagnostic-prompt_*.md | pbcopy

# Or directly in terminal
claude < diagnostic-prompt_*.md
```

### ChatGPT / Claude Web

1. Open the prompt file
2. Copy entire contents
3. Paste into chat interface
4. Wait for comprehensive analysis

### Local AI Models

```bash
# With llama.cpp or similar
cat diagnostic-prompt_*.md | llama-cli --model /path/to/model
```

## Output Interpretation

The AI will generate a report with these sections:

1. **Executive Summary**: Quick overview and root cause
2. **Cluster Information**: Platform, version, topology
3. **Problem Statement**: Detailed issue description
4. **Investigation Findings**: Data from cluster analysis
5. **Root Cause Analysis**: Primary cause with evidence
6. **Impact Assessment**: Business and technical impact
7. **Recommended Solution**: Immediate and long-term fixes
8. **Validation Steps**: How to verify the fix works
9. **Additional Observations**: Related findings

## Examples

### Example 1: Pod CrashLoopBackOff

```bash
./ocp-diagnostic-helper.sh /home/user/must-gather.local.123/

# When prompted:
Primary symptom: insights-runtime-extractor pods in CrashLoopBackOff
Affected components: openshift-insights namespace, insights-runtime-extractor DaemonSet
Observable evidence: [paste oc get pods output]
Timeline: Started 3 days ago
Frequency: Constant, with periodic restarts
```

### Example 2: Cluster Operator Degraded

```bash
./ocp-diagnostic-helper.sh /data/must-gather-production/

# When prompted:
Primary symptom: Authentication operator degraded
Affected components: authentication cluster operator
Observable evidence: [paste oc get co authentication -o yaml]
Timeline: After upgrade to 4.19.12
Frequency: Constant since upgrade
```

## FAQ

**Q: Can I run this on Windows?**
A: Use WSL (Windows Subsystem for Linux) or Git Bash. Native Windows support is not available.

**Q: Do I need OMC installed?**
A: No, but it's highly recommended for the quick analysis feature.

**Q: How long does the script take?**
A: 5-10 minutes for interactive input. Quick analysis adds 1-2 minutes.

**Q: Can I edit the generated prompt?**
A: Yes! The output is markdown and can be edited with any text editor.

**Q: What if I make a mistake during input?**
A: Press `Ctrl+C` to cancel and restart. Or edit the generated file afterward.

**Q: Does this work with MicroShift must-gather?**
A: It should work with any OpenShift/Kubernetes must-gather with similar structure.

## Contributing

Improvements welcome! Common enhancements:
- Support for more focus areas
- Integration with other diagnostic tools
- Config file support for non-interactive mode
- Support for multiple must-gather comparison

## License

MIT License - Free to use and modify

## Support

For issues or questions:
- OpenShift documentation: https://docs.openshift.com/
- Red Hat support: https://access.redhat.com/support
- Community: https://github.com/openshift/must-gather

## Version History

- **v1.0** (2025-01-19): Initial release
  - Interactive prompt generation
  - OMC integration
  - Quick analysis feature
  - Quick diagnostic script generation

---

**Happy troubleshooting!** 🔧
