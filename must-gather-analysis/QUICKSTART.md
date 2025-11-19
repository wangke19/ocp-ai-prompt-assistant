# Quick Start Guide - OpenShift Diagnostic Helper

Get started with AI-assisted OpenShift diagnostics in under 5 minutes!

## 📋 Prerequisites Check

```bash
# 1. Check if you have a must-gather
ls must-gather*/

# 2. Check if omc is installed (optional but recommended)
which omc || echo "OMC not installed - install from https://github.com/gmeghnag/omc"

# 3. Make scripts executable
chmod +x ocp-diagnostic-*.sh
```

## 🚀 Three Ways to Use

### Option 1: Express Mode (Fastest - 30 seconds)

**Best for**: Quick diagnostics when you know the issue

```bash
./ocp-diagnostic-express.sh <must-gather-path> "<symptom>" "<affected-component>"
```

**Example:**
```bash
./ocp-diagnostic-express.sh \
  must-gather.local.123/ \
  "Pods in CrashLoopBackOff" \
  "openshift-insights namespace"
```

**Output:**
- `diagnostic-prompt-express_TIMESTAMP.md` - AI-ready prompt
- `quick-diagnostic-express_TIMESTAMP.sh` - Quick check script

---

### Option 2: Interactive Mode (Recommended - 5-10 minutes)

**Best for**: Comprehensive diagnostics with detailed context

```bash
./ocp-diagnostic-helper.sh [must-gather-path]
```

**What it does:**
1. Auto-detects must-gather structure
2. Runs quick analysis (if omc available)
3. Guides you through 4 sections:
   - Problem Context
   - Environment Information
   - Analysis Focus
   - Additional Context
4. Generates comprehensive prompt

**Example session:**
```bash
./ocp-diagnostic-helper.sh must-gather.local.123/

# Follow the prompts:
# - Describe symptom
# - Paste evidence
# - Select focus area
# - Add context
```

**Output:**
- `diagnostic-prompt_TIMESTAMP.md` - Comprehensive AI prompt
- `quick-diagnostic_TIMESTAMP.sh` - Diagnostic script (optional)

---

### Option 3: Manual Template Use

**Best for**: Custom workflows or offline use

```bash
# 1. Copy the template
cp diagnostic-template.md my-diagnostic.md

# 2. Fill in manually with your editor
vim my-diagnostic.md

# 3. Use with AI
cat my-diagnostic.md | claude
```

---

## 📝 Real-World Examples

### Example 1: CrashLoopBackOff Pod

```bash
# Express mode
./ocp-diagnostic-express.sh \
  ./must-gather.local.2983011968230520427/ \
  "insights-runtime-extractor pods failing with liveness probe timeout" \
  "openshift-insights namespace"

# Interactive mode - fill in when prompted:
# Symptom: insights-runtime-extractor-pfwzt in CrashLoopBackOff
# Component: openshift-insights/insights-runtime-extractor DaemonSet
# Evidence: [paste oc get pods output showing CrashLoopBackOff]
# Timeline: Started 30 days ago
# Frequency: Constant with ~14,000 restarts
```

### Example 2: Degraded Operator

```bash
# Express mode
./ocp-diagnostic-express.sh \
  ~/must-gather-prod/ \
  "Authentication operator showing degraded status" \
  "authentication cluster operator"

# Output prompt to specific location
./ocp-diagnostic-express.sh \
  ~/must-gather-prod/ \
  "Authentication operator degraded" \
  "authentication CO" \
  -o ~/diagnostics/auth-issue.md
```

### Example 3: Node Issues

```bash
# Interactive mode with existing data
./ocp-diagnostic-helper.sh /data/must-gather-cluster-prod/

# When prompted, describe:
# - Symptom: 3 worker nodes stuck in NotReady state
# - Affected: worker-node-{1,2,3}
# - Evidence: [paste oc get nodes and oc describe node outputs]
# - Recent changes: Upgraded from 4.18 to 4.19 yesterday
```

---

## 🤖 Using Generated Prompts with AI

### With Claude Code (Terminal)

```bash
# Method 1: Direct file read
claude

# Then in Claude Code, use Read tool on the generated prompt file
# Or paste the content

# Method 2: Pipe to clipboard (macOS)
cat diagnostic-prompt_*.md | pbcopy

# Method 3: Linux clipboard
cat diagnostic-prompt_*.md | xclip -selection clipboard
```

### With ChatGPT / Claude Web

1. Open the generated prompt file:
   ```bash
   cat diagnostic-prompt_TIMESTAMP.md
   ```

2. Copy all content (Ctrl+A, Ctrl+C)

3. Paste into chat interface

4. Wait for analysis (usually 2-5 minutes)

### With Local AI Models

```bash
# LLama.cpp
cat diagnostic-prompt_*.md | llama-cli --model ./models/llama-70b.gguf

# Ollama
cat diagnostic-prompt_*.md | ollama run llama3:70b

# LM Studio
# Copy content and paste into LM Studio chat
```

---

## 🔍 Understanding the Output

### Diagnostic Prompt Structure

The generated prompt contains:

1. **Problem Context** - Your symptom and evidence
2. **Environment Info** - Must-gather details, versions
3. **Analysis Requirements** - Focus areas, components
4. **Methodology** - Step-by-step troubleshooting approach
5. **Required Tasks** - Checklist for AI to follow
6. **Deliverable Format** - Expected report structure
7. **Quick Start Commands** - Ready-to-use omc commands

### AI Report Structure

The AI will generate:

```
1. Executive Summary
   ├─ Issue overview
   ├─ Root cause (1-2 sentences)
   └─ Severity

2. Cluster Information
   ├─ Platform & version
   ├─ Node count & roles
   └─ Health status

3. Problem Statement
   ├─ Detailed symptoms
   ├─ Timeline
   └─ Current vs expected

4. Investigation Findings
   ├─ Cluster health data
   ├─ Component analysis
   ├─ Event correlation
   └─ Resource metrics

5. Root Cause Analysis
   ├─ Primary cause
   ├─ Contributing factors
   └─ Evidence

6. Impact Assessment
   ├─ Functional impact
   └─ Operational impact

7. Recommended Solution
   ├─ Immediate mitigation
   ├─ Permanent fix
   └─ Implementation steps

8. Validation Steps
   └─ How to verify fix

9. Additional Observations
```

---

## 🛠️ Quick Diagnostic Script

After generating the prompt, you also get a diagnostic script:

```bash
# Run it to get quick cluster snapshot
./quick-diagnostic_TIMESTAMP.sh

# It executes:
# - omc get clusteroperators
# - omc get nodes
# - omc get pods -A (problematic only)
# - omc get events -A (warnings/errors)
# - Cluster version info
```

**Use cases:**
- Quick health check before analysis
- Share cluster state with team
- Monitor changes over time

---

## 💡 Tips for Best Results

### 1. Provide Good Evidence

**Good:**
```
Observable evidence:
$ oc get pods -n openshift-insights
NAME                           READY   STATUS             RESTARTS
insights-runtime-extractor-pfwzt   2/3     CrashLoopBackOff   14157

$ oc describe pod insights-runtime-extractor-pfwzt -n openshift-insights
...
Events:
  Type     Reason     Message
  Warning  Unhealthy  Liveness probe failed: command timed out
```

**Poor:**
```
Observable evidence:
Some pods are failing
```

### 2. Be Specific About Components

**Good:** "openshift-insights namespace, insights-runtime-extractor DaemonSet, extractor container"

**Poor:** "insights stuff"

### 3. Include Timeline

**Good:** "Started 3 days ago after upgrade from 4.18.22 to 4.19.12, constant since then"

**Poor:** "recently"

### 4. Run Quick Analysis

If omc is available, always say **Yes** to quick analysis - it provides valuable context

### 5. Choose Right Focus Area

| Issue Type | Focus Area |
|------------|------------|
| Pod CrashLoopBackOff, ImagePullBackOff | Application/Pod |
| Service unreachable, DNS issues | Network/Connectivity |
| PVC pending, storage errors | Storage/PV/PVC |
| Operator degraded/unavailable | Cluster Operators |
| Node NotReady, pressure conditions | Node/Infrastructure |
| Slow performance, OOM kills | Performance/Resource |
| RBAC denials, auth failures | Security/RBAC |
| Multiple/unknown issues | Comprehensive |

---

## 🐛 Troubleshooting Common Issues

### Issue: "Failed to detect must-gather directory"

**Solution:**
```bash
# Check structure
ls -la must-gather*/

# Should contain:
# - quay-io-* subdirectory OR
# - cluster-scoped-resources/ and namespaces/ directories

# If it's nested, provide the full path:
./ocp-diagnostic-helper.sh must-gather.local.123/quay-io-openshift-*/
```

### Issue: "OMC not found"

**Solution:**
```bash
# Install omc (optional but recommended)
# Visit: https://github.com/gmeghnag/omc

# Or continue without it (quick analysis will be skipped)
# The script will still work!
```

### Issue: Multi-line input not working

**Solution:**
```bash
# Option 1: Type END on new line
Paste your content here
more content
END

# Option 2: Press Ctrl+D after pasting
```

### Issue: Generated prompt too generic

**Solution:**
Use **interactive mode** instead of express mode for more detailed prompts:
```bash
./ocp-diagnostic-helper.sh  # Interactive mode
# vs
./ocp-diagnostic-express.sh # Express mode
```

---

## 📊 Workflow Comparison

| Feature | Express Mode | Interactive Mode | Manual Template |
|---------|--------------|------------------|-----------------|
| **Time** | 30 seconds | 5-10 minutes | 15-30 minutes |
| **Detail** | Basic | Comprehensive | Full control |
| **Interaction** | Minimal (3 args) | Guided (10+ prompts) | Manual editing |
| **Quick Analysis** | ✅ Auto | ✅ Optional | ❌ Manual |
| **Best For** | Known issues | Unknown root cause | Custom workflows |
| **Output Quality** | Good | Excellent | Varies |

---

## 🎯 Next Steps After Generation

1. **Review the prompt**
   ```bash
   less diagnostic-prompt_*.md
   ```

2. **Run quick diagnostic** (optional)
   ```bash
   ./quick-diagnostic_*.sh > cluster-snapshot.txt
   ```

3. **Submit to AI**
   - Copy prompt to AI assistant
   - Wait for analysis (2-10 minutes)
   - Review generated report

4. **Act on recommendations**
   - Follow immediate mitigation steps
   - Test proposed fixes in dev first
   - Implement permanent solution
   - Validate with provided steps

5. **Document resolution**
   - Save AI report
   - Note what worked
   - Update runbooks

---

## 📚 Additional Resources

- **OpenShift Documentation**: https://docs.openshift.com/
- **Must-Gather Guide**: https://docs.openshift.com/container-platform/latest/support/gathering-cluster-data.html
- **OMC Tool**: https://github.com/gmeghnag/omc
- **Red Hat Support**: https://access.redhat.com/support

---

## ❓ FAQ

**Q: How accurate is AI diagnosis?**
A: Very accurate when given good data. The AI follows the same methodology as expert SREs. Always validate recommendations before applying.

**Q: Can I use this for production issues?**
A: Yes! This is designed for production diagnostics. Always test fixes in dev first when possible.

**Q: Does this replace Red Hat support?**
A: No, it complements it. Use this for initial diagnosis, then engage support for complex issues or patches.

**Q: What if AI can't find root cause?**
A: The prompt includes steps for the AI to ask clarifying questions. You can also re-run with more detail or use interactive mode.

**Q: Can I automate this?**
A: Yes! Express mode can be scripted. Example:
```bash
for mg in must-gather-*/; do
  ./ocp-diagnostic-express.sh "$mg" "$SYMPTOM" "$COMPONENT"
done
```

---

**Ready to diagnose?** Choose your mode and get started! 🚀
