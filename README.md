# OpenShift AI Prompt Assistant

AI-powered diagnostic and troubleshooting tools for OpenShift Container Platform (OCP).

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![OpenShift](https://img.shields.io/badge/OpenShift-4.x-red.svg)](https://www.openshift.com/)
[![AI-Powered](https://img.shields.io/badge/AI-Powered-blue.svg)](https://claude.ai)

---

## 🎯 Overview

This repository provides tools and utilities to create AI-ready diagnostic prompts for OpenShift cluster troubleshooting. Instead of manually crafting questions for AI assistants, these tools guide you through systematic data collection and generate comprehensive, structured prompts that follow OpenShift troubleshooting best practices.

### Why Use This?

- ⏱️ **Save Time**: Generate detailed diagnostic prompts in 30 seconds to 10 minutes (vs. 30+ minutes manually)
- 🎓 **Best Practices**: Built on OpenShift troubleshooting methodology (top-down, bottom-up, iterative)
- 🤖 **AI-Optimized**: Prompts are structured for maximum effectiveness with Claude, ChatGPT, and other LLMs
- 📊 **Comprehensive**: Ensures no diagnostic steps are missed
- 🔄 **Repeatable**: Standardized approach for consistent results

---

## 📦 Tools & Modules

### 🔍 [Must-Gather Analysis](./must-gather-analysis/)

**Purpose**: Transform OpenShift must-gather data into comprehensive AI diagnostic prompts

**What it does**:
- Auto-detects must-gather directory structure
- Runs quick cluster health analysis with OMC
- Guides you through systematic problem description
- Generates AI-ready diagnostic prompts
- Creates quick diagnostic scripts for validation

**Use cases**:
- Pod failures (CrashLoopBackOff, ImagePullBackOff, etc.)
- Degraded cluster operators
- Node issues (NotReady, resource pressure)
- Network/connectivity problems
- Storage/PV/PVC issues
- Performance degradation
- Unknown root cause investigations

**Quick start**:
```bash
cd must-gather-analysis/

# Express mode (30 seconds)
./ocp-diagnostic-express.sh <must-gather-path> "<symptom>" "<component>"

# Interactive mode (5-10 minutes)
./ocp-diagnostic-helper.sh [must-gather-path]

# Try the demo
./DEMO.sh
```

📖 **Full documentation**: [must-gather-analysis/INDEX.md](./must-gather-analysis/INDEX.md)

---

## 🚀 Getting Started

### Prerequisites

**Required**:
- Bash shell (Linux/macOS/WSL on Windows)
- OpenShift must-gather data (`oc adm must-gather`)

**Optional but recommended**:
- [OMC](https://github.com/gmeghnag/omc) - OpenShift Must-Gather Client
- AI assistant access (Claude Code, ChatGPT, local LLM, etc.)

### Installation

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/ocp-ai-prompt-assistant.git
cd ocp-ai-prompt-assistant

# Make scripts executable
chmod +x must-gather-analysis/*.sh

# Run demo to see it in action
cd must-gather-analysis/
./DEMO.sh
```

### Quick Example

```bash
# 1. Collect must-gather from your cluster
oc adm must-gather --dest-dir=/tmp/my-issue

# 2. Generate diagnostic prompt
cd must-gather-analysis/
./ocp-diagnostic-express.sh \
  /tmp/my-issue/ \
  "Pods in CrashLoopBackOff" \
  "openshift-insights namespace"

# 3. Use generated prompt with AI
cat diagnostic-prompt-express_*.md

# Copy to Claude Code, ChatGPT, or your preferred AI assistant

# 4. Get comprehensive analysis with:
#    - Root cause identification
#    - Impact assessment
#    - Remediation steps
#    - Validation procedures
```

---

## 📚 Documentation

### Main Repository
- **This README** - Overview and getting started
- **[CONTRIBUTING.md](./CONTRIBUTING.md)** - Contribution guidelines *(coming soon)*
- **[LICENSE](./LICENSE)** - MIT License *(coming soon)*

### Must-Gather Analysis Module
- **[INDEX.md](./must-gather-analysis/INDEX.md)** - Module overview and navigation
- **[QUICKSTART.md](./must-gather-analysis/QUICKSTART.md)** - 5-minute quick start guide
- **[README.md](./must-gather-analysis/README-diagnostic-helper.md)** - Complete user manual
- **Interactive Demo** - Run `./must-gather-analysis/DEMO.sh`

---

## 🔧 Supported OpenShift Versions

- ✅ OpenShift 4.x (4.10+)
- ✅ OpenShift 3.11 (with must-gather)
- ⚠️ Earlier versions may work but are untested

---

## 🎓 How It Works

### The Problem

When troubleshooting OpenShift issues with AI assistance, you typically need to:

1. Describe the problem clearly
2. Provide relevant cluster data
3. Include logs, events, and configurations
4. Structure the request for effective analysis
5. Ensure no diagnostic steps are missed

This is time-consuming and error-prone.

### The Solution

This toolkit:

1. **Guides** you through systematic data collection
2. **Extracts** relevant information from must-gather
3. **Structures** the diagnostic request following OpenShift troubleshooting methodology
4. **Generates** comprehensive, AI-ready prompts
5. **Ensures** all critical diagnostic steps are included

### The Result

AI assistants receive well-structured prompts that enable them to:

- Apply OpenShift troubleshooting best practices
- Systematically analyze cluster state
- Identify root causes with supporting evidence
- Provide actionable remediation steps
- Include validation procedures

---

## 🌟 Features

### Must-Gather Analysis Module

#### ⚡ Express Mode
- **Time**: 30 seconds
- **Input**: 3 arguments (path, symptom, component)
- **Output**: AI-ready diagnostic prompt
- **Best for**: Known issues, quick turnaround

#### 📋 Interactive Mode
- **Time**: 5-10 minutes
- **Input**: Step-by-step guided prompts
- **Output**: Comprehensive diagnostic prompt
- **Best for**: Complex issues, unknown root cause

#### 🔍 Quick Analysis
- Auto-detects must-gather structure
- Runs cluster health checks with OMC
- Identifies problematic components
- Provides context for prompt generation

#### 📄 Generated Outputs
- **Diagnostic Prompt** - Markdown file ready for AI
- **Quick Diagnostic Script** - Shell script for cluster health checks
- **Structured Format** - 9-section comprehensive analysis request

---

## 💡 Real-World Example

### Scenario: Pods in CrashLoopBackOff

**Before (Manual approach - 30+ minutes)**:
```
User: "My pods are failing. Can you help?"

AI: "I need more information. What pods? What errors? What does the cluster look like?"

User: [scrambles to gather logs, events, describe issue...]

AI: "Can you provide the pod description and events?"

User: [more back-and-forth...]
```

**After (With this tool - 2 minutes)**:
```bash
./ocp-diagnostic-express.sh \
  must-gather/ \
  "insights-runtime-extractor pods in CrashLoopBackOff with liveness probe timeout" \
  "openshift-insights namespace"

# Generated prompt includes:
# - Symptom description
# - Quick cluster analysis
# - Affected components
# - Troubleshooting methodology
# - Required analysis tasks
# - Expected deliverable format

# AI immediately provides:
# ✓ Root cause: Liveness probe timeout too aggressive
# ✓ Evidence: Events show 33,541 timeout failures
# ✓ Solution: Increase timeoutSeconds from 1s to 5s
# ✓ Validation: Monitor pod restarts stop
```

**Result**: Issue diagnosed and resolved in minutes instead of hours.

---

## 🎯 Use Cases by Scenario

| Scenario | Tool | Mode | Time | Outcome |
|----------|------|------|------|---------|
| Pod CrashLoopBackOff | must-gather-analysis | Express | 30s | Root cause + fix |
| Operator degraded | must-gather-analysis | Interactive | 5m | Detailed analysis |
| Unknown cluster issue | must-gather-analysis | Interactive | 10m | Comprehensive diagnosis |
| Node NotReady | must-gather-analysis | Express | 30s | Infrastructure analysis |
| Performance degradation | must-gather-analysis | Interactive | 10m | Resource bottleneck ID |
| Network connectivity | must-gather-analysis | Interactive | 5m | Network path analysis |

---

## 🤖 AI Assistant Compatibility

This toolkit generates prompts optimized for:

- ✅ **Claude Code** (Anthropic) - Terminal-based
- ✅ **Claude** (Web) - claude.ai
- ✅ **ChatGPT** (OpenAI) - GPT-4, GPT-4-turbo
- ✅ **Local LLMs** - Llama, Mistral, etc.
- ✅ **Other AI assistants** - Any LLM with context understanding

### Platform-Specific Usage

**Claude Code (Terminal)**:
```bash
cat diagnostic-prompt_*.md
# Paste in Claude Code or use Read tool
```

**ChatGPT/Claude Web**:
```bash
# macOS
cat diagnostic-prompt_*.md | pbcopy

# Linux
cat diagnostic-prompt_*.md | xclip -selection clipboard
```

**Local LLM**:
```bash
cat diagnostic-prompt_*.md | ollama run llama3:70b
```

---

## 📊 Workflow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    OpenShift Cluster                        │
│                         ↓                                   │
│                  (Issue occurs)                             │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│              Collect Must-Gather                            │
│         $ oc adm must-gather                                │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│         OCP AI Prompt Assistant                             │
│         (must-gather-analysis)                              │
│                                                             │
│    ┌──────────────┐      ┌────────────────┐               │
│    │ Express Mode │  OR  │ Interactive    │               │
│    │  (30 sec)    │      │ Mode (5-10min) │               │
│    └──────────────┘      └────────────────┘               │
│            ↓                      ↓                         │
│     Auto-analysis          Guided prompts                  │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│         Generated Diagnostic Prompt                         │
│         (diagnostic-prompt_TIMESTAMP.md)                    │
│                                                             │
│    • Problem context                                        │
│    • Cluster information                                    │
│    • Analysis requirements                                  │
│    • Troubleshooting methodology                            │
│    • Expected deliverable format                            │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│              AI Assistant Analysis                          │
│     (Claude Code, ChatGPT, Local LLM)                       │
│                                                             │
│    • Cluster health analysis                                │
│    • Root cause identification                              │
│    • Evidence correlation                                   │
│    • Impact assessment                                      │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│         Comprehensive Diagnostic Report                     │
│                                                             │
│    1. Executive Summary                                     │
│    2. Cluster Information                                   │
│    3. Problem Statement                                     │
│    4. Investigation Findings                                │
│    5. Root Cause Analysis                                   │
│    6. Impact Assessment                                     │
│    7. Recommended Solution                                  │
│    8. Validation Steps                                      │
│    9. Additional Observations                               │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│              Apply Fix & Validate                           │
│         (Using quick-diagnostic script)                     │
└─────────────────────────────────────────────────────────────┘
                          ↓
                   Issue Resolved ✓
```

---

## 🛣️ Roadmap

### Current (v1.0)
- ✅ Must-gather analysis module
- ✅ Express and interactive modes
- ✅ OMC integration
- ✅ Comprehensive documentation
- ✅ Interactive demo

### Planned (v1.1)
- ⏳ Config file support for automation
- ⏳ Multi-must-gather comparison
- ⏳ Template customization
- ⏳ Batch processing support

### Future (v2.0)
- 💭 Live cluster analysis (without must-gather)
- 💭 Integration with monitoring systems
- 💭 Historical issue database
- 💭 Automated fix validation
- 💭 Additional modules:
  - Upgrade analysis
  - Capacity planning
  - Security audit
  - Performance tuning

---

## 🤝 Contributing

Contributions are welcome! This project is in active development.

**Ways to contribute**:
- 🐛 Report bugs or issues
- 💡 Suggest new features or improvements
- 📝 Improve documentation
- 🔧 Submit pull requests
- ⭐ Star the repository if you find it useful

**Coming soon**: CONTRIBUTING.md with detailed guidelines

---

## 📄 License

This project is licensed under the MIT License.

**In short**: You can use, modify, and distribute this freely. Attribution appreciated but not required.

---

## 🙏 Acknowledgments

- **OpenShift Team** - For excellent documentation and must-gather tooling
- **OMC Project** - For the must-gather client tool
- **Anthropic/OpenAI** - For AI technologies that make this possible
- **Community** - For feedback and contributions

---

## 📞 Support & Resources

### Documentation
- **Quick Start**: [must-gather-analysis/QUICKSTART.md](./must-gather-analysis/QUICKSTART.md)
- **Full Manual**: [must-gather-analysis/README-diagnostic-helper.md](./must-gather-analysis/README-diagnostic-helper.md)
- **Interactive Demo**: `./must-gather-analysis/DEMO.sh`

### OpenShift Resources
- **Official Docs**: https://docs.openshift.com/
- **Must-Gather Guide**: https://docs.openshift.com/container-platform/latest/support/gathering-cluster-data.html
- **Red Hat Support**: https://access.redhat.com/support

### Tools
- **OMC**: https://github.com/gmeghnag/omc
- **OpenShift CLI**: https://docs.openshift.com/container-platform/latest/cli_reference/openshift_cli/getting-started-cli.html

### Community
- **Issues**: [GitHub Issues](https://github.com/YOUR_USERNAME/ocp-ai-prompt-assistant/issues)
- **Discussions**: [GitHub Discussions](https://github.com/YOUR_USERNAME/ocp-ai-prompt-assistant/discussions)

---

## 🎓 About

**Created**: 2025-11-19
**Author**: @wangke19
**Purpose**: Democratize access to expert-level OpenShift diagnostics through AI assistance

---

## ⭐ Star History

If you find this project useful, please consider giving it a star! ⭐

It helps others discover these tools and motivates continued development.

---

<div align="center">

**[Get Started](./must-gather-analysis/QUICKSTART.md)** •
**[Documentation](./must-gather-analysis/INDEX.md)** •
**[Demo](./must-gather-analysis/DEMO.sh)** •
**[Issues](https://github.com/YOUR_USERNAME/ocp-ai-prompt-assistant/issues)**

Made with ❤️ for the OpenShift community

</div>
