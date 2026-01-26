awk -F'=' '
{
    # Determine the key for deduplication
    # If not continuing a previous line, this line contains a new key
    if (!continuing) {
        current_key = $1
    }

    # If this is a new key we have already seen, skip it
    if (!continuing && seen[current_key]++) {
        skip_block = 1
    } else if (!continuing) {
        skip_block = 0
    }

    # If we are in a skip zone, check if we need to keep skipping
    if (skip_block) {
        continuing = ($0 ~ /\\$/)
        next
    }

    # --- Processing for non-duplicate lines ---

    if ($0 ~ /\\$/) {
        if (!continuing) {
            # Start of multi-line: Use | and NO quotes
            val = substr($0, length(current_key) + 2)
            printf "- %s= |\n  %s\n", current_key, val
            continuing = 1
        } else {
            # Middle of multi-line: Indent only
            printf "  %s\n", $0
        }
    } else {
        if (continuing) {
            # Final line of a multi-line block
            printf "  %s\n", $0
            continuing = 0
        } else {
            # Standard single-line property: Apply double quotes
            val = substr($0, length(current_key) + 2)
            printf "- %s=\"%s\"\n", current_key, val
        }
    }
}' result > results_dup.yaml
