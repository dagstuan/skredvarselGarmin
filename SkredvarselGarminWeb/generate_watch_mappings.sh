function generate_csharp_switch() {
    for folder in "$1"*/; do
        if [ -f "${folder}compiler.json" ]; then
            display_name=$(jq -r '.displayName' "${folder}compiler.json")
            part_numbers=$(jq -c '.partNumbers[]' "${folder}compiler.json")
            while IFS= read -r part_number; do
                number=$(echo "${part_number}" | jq -r '.number')
                echo "\"${number}\" => \"${display_name}\","
            done <<< "$part_numbers"
        fi
    done
}

generate_csharp_switch "$1" > output.cs
