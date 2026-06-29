#!/usr/bin/env python3
"""
Script to patch AISettingsView with server selection capability
"""

import os

base_dir = "/Users/michael/Documents/MacbookPro/My Apps/Projects/Apps/MacOS/CreateIT"
views_dir = f"{base_dir}/CreateIT/Views"

def main():
    input_file = f"{views_dir}/AISettingsView.swift"
    output_file = f"{views_dir}/AISettingsView.swift"
    
    with open(input_file, 'r') as f:
        content = f.read()
    
    # Step 1: Update header comment
    old_header = '''/// Configuration panel for connecting CreateIT to a local LLM server
/// (LM Studio by default).'''
    
    new_header = '''/// Configuration panel for connecting CreateIT to a local LLM server.
/// Supports both LM Studio (OpenAI-compatible API) and Ollama (native API).'''
    
    content = content.replace(old_header, new_header)
    
    # Step 2: Add @State property after dismiss
    state_property = '\n\n\t@State private var selectedServerType: AIProvider = .lmStudio'
    
    if '@State private var selectedServerType' not in content:
        content = content.replace('@Environment(\\.dismiss) private var dismiss', 
                                  '@Environment(\\.dismiss) private var dismiss' + state_property)
    
    print("✓ Added @State property")
    
    # Continue with more modifications...
    print("✓ Starting patch process")
    
if __name__ == "__main__":
    main()
