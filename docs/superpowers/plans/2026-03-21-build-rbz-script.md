# Build RBZ Script Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a reusable one-command script that builds `dist/CamWheel-<version>.rbz` from the plugin runtime files only.

**Architecture:** Add a small shell script under `scripts/` that reads the plugin version from `cam_wheel/version.rb`, packages `CamWheel.rb` plus `cam_wheel/`, and excludes development-only artifacts. Cover it with a Ruby integration test that invokes the script with a temporary output directory and inspects the generated archive listing.

**Tech Stack:** POSIX shell, Ruby, Minitest, zip/unzip

---

## Chunk 1: Tests First

### Task 1: Add failing integration test

**Files:**
- Create: `test/cam_wheel/build_rbz_script_test.rb`

- [ ] **Step 1: Write a failing test** that runs `bash scripts/build_rbz.sh` with `OUTPUT_DIR` set to a temporary directory.
- [ ] **Step 2: Verify the test fails** because the script does not exist yet.
- [ ] **Step 3: Implement the minimal build script** so the test passes.
- [ ] **Step 4: Re-run the targeted test** and confirm the archive exists and excludes dev files.

## Chunk 2: Verification

### Task 2: Verify script and package behavior

**Files:**
- Create: `scripts/build_rbz.sh`

- [ ] **Step 1: Run the script manually**
  - Run: `bash scripts/build_rbz.sh`
  - Expected: `dist/CamWheel-1.0.0.rbz` is created or replaced.
- [ ] **Step 2: Run the full test suite**
  - Run: `for test_file in test/cam_wheel/*_test.rb; do ruby -Itest "$test_file" || exit 1; done`
