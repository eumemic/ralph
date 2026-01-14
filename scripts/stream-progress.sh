#!/bin/bash
# stream-progress.sh - Format Claude stream-json output for humans
#
# Reads JSONL from stdin and outputs human-readable progress.
# Filters out subagent messages before transcription.
# Uses claude-transcriber library: pip install claude-transcriber

jq -c 'select(.parent_tool_use_id == null)' | claude-transcriber
