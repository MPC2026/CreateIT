# Universal AI Context Purge & Roadmap Compaction Protocol

When your conversation context climbs high, or if a local model enters an infinite looping pattern, execute this protocol to automatically strip away completed tasks, clear out background memory channels, and restore your peak local processing speed.

---

## 🛑 STEP 1: Run the Dynamic Roadmap Compactor Script

Open your VS Code integrated terminal (`Ctrl + \``) or standard Mac Terminal application. First, press **`Ctrl + C`** to clear any old frozen text prompts, then copy and paste the entire command block below all at once and press **Enter**.

```zsh
# Execute script natively within a clean local sub-shell function layout
() {
    local PROJECT_ROOT=$(pwd)
    local TODO_PATH="$PROJECT_ROOT/TODO.md"
    local BACKUP_DIR="$PROJECT_ROOT/PriorBuilds/chat_backups"
    local TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
    local TEMP_TODO

    echo "🚨 Initializing Automated Context Compaction inside: $PROJECT_ROOT"
    mkdir -p "$BACKUP_DIR"

    if [ -f "$TODO_PATH" ]; then
        # 1. Take a secure snapshot of your current file state before modifying
        cp "$TODO_PATH" "$BACKUP_DIR/TODO_backup_$TIMESTAMP.md"
        echo "💾 Secure backup of TODO.md archived in PriorBuilds folder."

        # 2. Extract title lines and filter out ONLY items marked as completed with literal [x]
        TEMP_TODO=$(mktemp)
        
        # Precise line-by-line streaming filter to preserve pending task structures
        while IFS= read -r line || [[ -n "$line" ]]; do
            # Strict literal matching for closed brackets containing 'x'
            if [[ "$line" == *"- [x]"* ]] || [[ "$line" == *"- [x] "* ]]; then
                continue # Skip completed checkmarks safely
            fi
            echo "$line" >> "$TEMP_TODO"
        done < "$TODO_PATH"
        
        mv "$TEMP_TODO" "$TODO_PATH"
        echo "📝 Completed tasks purged from TODO.md successfully!"
    else
        echo "⚠️ TODO.md file not found in this folder. Initializing clean template roadmap."
        echo "# Project Roadmap" > "$TODO_PATH"
        echo "" >> "$TODO_PATH"
        echo "## Phase 1: Initial Checklist" >> "$TODO_PATH"
        echo "- [ ] Execute initial compilation fix pass" >> "$TODO_PATH"
    fi

    # 3. Forcefully terminate running server sub-threads and flush RAM context slots
    echo "🧹 Purging background RAM context logs..."
    killall -9 llama-server 2>/dev/null
    
    # Corrected native server flush endpoints with full parameters
    ollama stop MPC-Coder 2>/dev/null
    ollama stop MPC-Ornith 2>/dev/null

    echo ""
    echo "⚡ SUCCESS: Workspace memory channels fully cleared!"
    echo "========================================================================"
    echo "👉 NEXT STEP: Click 'New Chat (+)' and paste your 1-line rule shortcut:"
    echo "@file:TODO.md @file:WizardState.swift Execute next task."
    echo "========================================================================"
    echo ""
}
```

---

## 🧹 STEP 2: Wipe the Editor Window History Trail

Go directly to your active VS Code panel and click the **New Chat (+)** drawer button. 

* **Why this is mandatory:** The automated macro above clears your background server's RAM context lanes and compacts your roadmap file, but clicking this icon is required to forcefully discard the heavy history data block out of your editor's visual extension memory panel.

---

## 🏎️ STEP 3: Re-Launch Your Hyper-Drive Session

In your brand-new, clean chat input container box, drop your automated 1-line rule shortcut string and hit **Enter** to resume coding with zero loading latency:

```text
@file:TODO.md @file:WizardState.swift Execute next task.
```
