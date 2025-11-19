# OpenShift Diagnostic Helper - Complete Package

**Created**: 2025-11-19
**Purpose**: Step-by-step tools for AI-assisted OpenShift cluster diagnostics

---

## 📦 Package Contents

This package includes everything you need to create comprehensive diagnostic prompts for AI analysis of OpenShift cluster issues.

### 🛠️ Scripts (Executable)

| File | Purpose | Mode | Time |
|------|---------|------|------|
| `ocp-diagnostic-helper.sh` | Full interactive diagnostic prompt generator | Interactive | 5-10 min |
| `ocp-diagnostic-express.sh` | Quick diagnostic prompt generator | Command-line | 30 sec |
| `DEMO.sh` | Interactive demonstration of both tools | Interactive | 5 min |

### 📚 Documentation

| File | Purpose | Audience |
|------|---------|----------|
| `README-diagnostic-helper.md` | Complete user manual with all features | All users |
| `QUICKSTART.md` | Get started in under 5 minutes | New users |
| `INDEX.md` | This file - package overview | All users |

### 📋 Template (Reference)

The AI-ready diagnostic template is embedded in the scripts but follows this structure:

```markdown
# OpenShift Cluster Diagnostic Analysis Request
├── Problem Context
│   ├── Symptom Description
│   ├── Affected Components
│   ├── Observable Evidence
│   ├── Timeline
│   └── Initial Observations
├── Environment Information
│   ├── Must-Gather Location
│   └── OpenShift Version
├── Analysis Requirements
│   ├── Primary Focus Area
│   └── Specific Components
├── Analysis Framework
│   ├── OpenShift Troubleshooting Methodology
│   ├── Top-Down Approach
│   ├── Bottom-Up Approach
│   └── Root Cause Identification
├── Required Analysis Tasks (Checklist)
├── Deliverable Format (9-section report)
└── Quick Start Commands
```

---

## 🚀 Quick Start

Choose your path based on your needs:

### Path 1: I Want to See a Demo First

```bash
./DEMO.sh
```

This interactive demo shows you:
- How express mode works
- What interactive mode looks like
- How to use OMC for quick analysis
- Example outputs

**Time**: 5 minutes
**Best for**: First-time users

---

### Path 2: I Need Quick Results Now

```bash
./ocp-diagnostic-express.sh <must-gather-path> "<symptom>" "<component>"
```

**Example:**
```bash
./ocp-diagnostic-express.sh \
  must-gather.local.123/ \
  "Pods in CrashLoopBackOff" \
  "openshift-insights"
```

**Time**: 30 seconds
**Best for**: Known issues, quick diagnostics

---

### Path 3: I Want Comprehensive Analysis

```bash
./ocp-diagnostic-helper.sh [must-gather-path]
```

Follow the interactive prompts to create a detailed diagnostic request.

**Time**: 5-10 minutes
**Best for**: Unknown root cause, complex issues

---

### Path 4: I Want to Read First

```bash
# Quick overview
less QUICKSTART.md

# Complete documentation
less README-diagnostic-helper.md
```

**Time**: 10-15 minutes reading
**Best for**: Understanding all features

---

## 📖 Documentation Guide

### Which Document Should I Read?

```
Start Here → QUICKSTART.md
    ↓
    Is this enough?
    ├─ Yes → Use the scripts!
    └─ No → README-diagnostic-helper.md
              ↓
              Need examples?
              └─ Run ./DEMO.sh
```

### Documentation Comparison

| Document | Length | Content | When to Use |
|----------|--------|---------|-------------|
| **INDEX.md** | 1 page | Package overview | Starting point |
| **QUICKSTART.md** | 5 pages | Practical examples & workflows | Learning to use |
| **README.md** | 10 pages | Complete reference | Deep dive |
| **DEMO.sh** | Interactive | Hands-on tutorial | Visual learners |

---

## 🎯 Common Use Cases

### Use Case 1: Pod Failing (CrashLoopBackOff, ImagePull, etc.)

```bash
# Express mode
./ocp-diagnostic-express.sh \
  /path/to/must-gather/ \
  "Pod X in CrashLoopBackOff with error Y" \
  "namespace/pod-name"

# Interactive mode - provides more context
./ocp-diagnostic-helper.sh /path/to/must-gather/
# Choose: 1) Application/Pod issues
```

### Use Case 2: Cluster Operator Degraded

```bash
./ocp-diagnostic-express.sh \
  /path/to/must-gather/ \
  "Authentication operator degraded" \
  "authentication cluster operator"

# Or interactive for detailed analysis
./ocp-diagnostic-helper.sh /path/to/must-gather/
# Choose: 4) Cluster Operators
```

### Use Case 3: Node Issues

```bash
./ocp-diagnostic-express.sh \
  /path/to/must-gather/ \
  "Worker nodes in NotReady state" \
  "worker-node-1,worker-node-2"

# Or interactive
./ocp-diagnostic-helper.sh /path/to/must-gather/
# Choose: 5) Node/Infrastructure
```

### Use Case 4: Unknown Issue - Need Investigation

```bash
# Always use interactive mode for unknown issues
./ocp-diagnostic-helper.sh /path/to/must-gather/
# Choose: 8) Comprehensive (all areas)
```

### Use Case 5: Performance Issues

```bash
./ocp-diagnostic-helper.sh /path/to/must-gather/
# Choose: 6) Performance/Resource
# Provide memory/CPU observations
```

---

## 🔄 Complete Workflow Example

Real-world scenario from collection to resolution:

```bash
# 1. Collect must-gather from cluster
oc adm must-gather --dest-dir=/tmp/my-cluster-issue

# 2. Run diagnostic helper
cd /tmp/
./ocp-diagnostic-express.sh \
  my-cluster-issue/ \
  "insights-runtime-extractor pods failing with liveness probe timeout" \
  "openshift-insights namespace"

# Output: diagnostic-prompt-express_20251119_140530.md
#         quick-diagnostic-express_20251119_140530.sh

# 3. Review prompt
less diagnostic-prompt-express_20251119_140530.md

# 4. Copy to AI (example with Claude Code)
cat diagnostic-prompt-express_20251119_140530.md

# 5. Paste into Claude Code and receive analysis
# AI returns comprehensive report with:
# - Root cause: Liveness probe timeout too aggressive (1s)
# - Solution: Increase timeoutSeconds to 3-5s
# - Validation steps

# 6. Apply fix
oc patch daemonset insights-runtime-extractor \
  -n openshift-insights \
  --type=merge \
  -p '{"spec":{"template":{"spec":{"containers":[{"name":"extractor","livenessProbe":{"timeoutSeconds":5}}]}}}}'

# 7. Validate with quick diagnostic
./quick-diagnostic-express_20251119_140530.sh

# 8. Verify fix
oc get pods -n openshift-insights
# All pods now 3/3 Running, restarts stopped

# 9. Document resolution
echo "Fixed by increasing liveness probe timeout" >> resolution-notes.txt
```

---

## 🛠️ System Requirements

### Required
- **Bash shell** (Linux/macOS/WSL)
- **Must-gather data** from OpenShift cluster
  - Collect with: `oc adm must-gather`

### Optional (Recommended)
- **OMC** (OpenShift Must-Gather Client)
  - Download: https://github.com/gmeghnag/omc
  - Enables quick analysis feature
  - Scripts work without it, but with reduced functionality

### Storage
- ~50MB for scripts and documentation
- Variable for must-gather (typically 100MB-2GB)
- Generated prompts: ~50-100KB each

---

## 🎓 Learning Path

### Beginner
1. ✅ Read QUICKSTART.md (10 min)
2. ✅ Run ./DEMO.sh (5 min)
3. ✅ Try express mode on sample must-gather
4. ✅ Review generated prompt
5. ✅ Use prompt with AI

### Intermediate
1. ✅ Complete beginner path
2. ✅ Read README-diagnostic-helper.md
3. ✅ Try interactive mode
4. ✅ Install and use OMC
5. ✅ Compare express vs interactive outputs

### Advanced
1. ✅ Complete intermediate path
2. ✅ Customize prompts for your environment
3. ✅ Create wrapper scripts for automation
4. ✅ Integrate with CI/CD pipelines
5. ✅ Contribute improvements

---

## 🧪 Testing the Package

### Quick Test

```bash
# 1. Verify scripts are executable
ls -l *.sh

# Expected: -rwx--x--x permissions on all .sh files

# 2. Run help
./ocp-diagnostic-express.sh --help
./ocp-diagnostic-helper.sh  # Will start interactive mode, Ctrl+C to exit

# 3. Run demo
./DEMO.sh
```

### Full Test

```bash
# Use with your actual must-gather
./ocp-diagnostic-express.sh \
  /path/to/your/must-gather/ \
  "Test symptom" \
  "Test component"

# Verify output
ls -l diagnostic-prompt-express_*.md
head -20 diagnostic-prompt-express_*.md
```

---

## 📊 Output Files

After running the scripts, you'll have:

### From Express Mode
```
diagnostic-prompt-express_YYYYMMDD_HHMMSS.md  - AI-ready prompt
quick-diagnostic-express_YYYYMMDD_HHMMSS.sh   - Quick health check script
```

### From Interactive Mode
```
diagnostic-prompt_YYYYMMDD_HHMMSS.md          - Comprehensive AI prompt
quick-diagnostic_YYYYMMDD_HHMMSS.sh           - Quick health check script (optional)
```

### Quick Diagnostic Script Usage
```bash
# Run anytime to get cluster snapshot
./quick-diagnostic_*.sh

# Or save output
./quick-diagnostic_*.sh > cluster-health-report.txt
```

---

## 🤝 Using with AI Assistants

### Claude Code (Terminal)
```bash
# Open the prompt file in Claude Code
cat diagnostic-prompt_*.md

# Claude Code can read the file directly or you can paste
```

### ChatGPT / Claude Web
```bash
# Copy to clipboard (macOS)
cat diagnostic-prompt_*.md | pbcopy

# Linux
cat diagnostic-prompt_*.md | xclip -selection clipboard

# Then paste in web interface
```

### Local AI Models
```bash
# LLama.cpp
cat diagnostic-prompt_*.md | llama-cli --model ./model.gguf

# Ollama
cat diagnostic-prompt_*.md | ollama run llama3

# LM Studio
# Copy and paste into LM Studio chat
```

---

## 💡 Pro Tips

### Tip 1: Use Quick Analysis
Always say "Yes" to quick analysis if OMC is available - it provides valuable context

### Tip 2: Keep Must-Gathers Organized
```bash
mkdir -p ~/must-gathers/$(date +%Y-%m)/
mv must-gather.local.* ~/must-gathers/$(date +%Y-%m)/issue-name/
```

### Tip 3: Save Generated Prompts
```bash
mkdir -p ~/diagnostics/
mv diagnostic-prompt_*.md ~/diagnostics/issue-name-$(date +%Y%m%d).md
```

### Tip 4: Version Control Your Resolutions
```bash
git init ~/cluster-issues/
cd ~/cluster-issues/
# Save prompts, AI reports, and fixes
git add .
git commit -m "Fixed insights-runtime-extractor liveness probe timeout"
```

### Tip 5: Create Aliases
```bash
# Add to ~/.bashrc or ~/.zshrc
alias ocp-diagnose='/path/to/ocp-diagnostic-express.sh'
alias ocp-diagnose-full='/path/to/ocp-diagnostic-helper.sh'
```

---

## 🐛 Troubleshooting

### Script won't run
```bash
# Make executable
chmod +x ocp-diagnostic-*.sh DEMO.sh

# Check permissions
ls -l *.sh
```

### "Must-gather not found"
```bash
# Verify path
ls /path/to/must-gather/

# Should contain quay-io-* subdirectory or cluster-scoped-resources/
```

### "OMC not found"
```bash
# Optional - scripts work without it
# Install from: https://github.com/gmeghnag/omc

# Or continue without quick analysis
```

### Multi-line input issues
```bash
# Type 'END' on new line to finish
# Or press Ctrl+D
```

---

## 📞 Support & Resources

- **OpenShift Docs**: https://docs.openshift.com/
- **Must-Gather Guide**: https://docs.openshift.com/container-platform/latest/support/gathering-cluster-data.html
- **OMC Tool**: https://github.com/gmeghnag/omc
- **Red Hat Support**: https://access.redhat.com/support

---

## 📝 Version History

**v1.0** (2025-11-19)
- Initial release
- Interactive mode (ocp-diagnostic-helper.sh)
- Express mode (ocp-diagnostic-express.sh)
- OMC integration for quick analysis
- Comprehensive documentation
- Interactive demo

---

## 🎉 You're Ready!

You now have everything you need for AI-assisted OpenShift diagnostics.

**Next steps:**

1. ✅ Choose your mode (express or interactive)
2. ✅ Generate a diagnostic prompt
3. ✅ Submit to your AI assistant
4. ✅ Get root cause analysis
5. ✅ Apply recommended fixes
6. ✅ Validate results

**Questions?** Check the documentation:
- Quick questions → QUICKSTART.md
- Detailed info → README-diagnostic-helper.md
- Hands-on learning → ./DEMO.sh

---

**Happy troubleshooting!** 🚀🔧
