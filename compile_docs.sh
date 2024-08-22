#!/bin/bash

# Output file
output_file="dockerfile-makefile-cmakelists-for-all-depends-and-libsnark.md"

# Flags for file types (default to include all)
include_markdown=true
include_txt=true
include_dockerfile=true
include_makefile=true

# Parse command-line arguments
for arg in "$@"
do
    case $arg in
        --no-markdown)
        include_markdown=false
        shift
        ;;
        --no-txt)
        include_txt=false
        shift
        ;;
        --no-dockerfile)
        include_dockerfile=false
        shift
        ;;
        --no-makefile)
        include_makefile=false
        shift
        ;;
    esac
done

# Remove the output file if it already exists
rm -f "$output_file"

# Function to add a header for each file with its relative path
add_header() {
    echo -e "\n## File: $1\n" >> "$output_file"
}

# Function to process files
process_files() {
    local pattern=$1
    local syntax=$2
    find . -type f -name "$pattern" | while read -r file; do
        add_header "${file#./}"
        if [ -n "$syntax" ]; then
            echo '```'"$syntax" >> "$output_file"
        fi
        cat "$file" >> "$output_file"
        if [ -n "$syntax" ]; then
            echo '```' >> "$output_file"
        fi
    done
}

# Compile Markdown files (including variants) if not excluded
if $include_markdown; then
    process_files "*.md"
    process_files "*.mdx"
    process_files "*.markdown"
fi

# Compile text files if not excluded
if $include_txt; then
    process_files "*.txt" "text"
fi

# Add Dockerfile if it exists and is not excluded
if $include_dockerfile; then
    find . -type f -name "Dockerfile" | while read -r file; do
        add_header "${file#./}"
        echo '```dockerfile' >> "$output_file"
        cat "$file" >> "$output_file"
        echo '```' >> "$output_file"
    done
fi

# Add Makefile if it exists and is not excluded
if $include_makefile; then
    find . -type f -name "Makefile" | while read -r file; do
        add_header "${file#./}"
        echo '```makefile' >> "$output_file"
        cat "$file" >> "$output_file"
        echo '```' >> "$output_file"
    done
fi

echo "Documentation compiled into $output_file"