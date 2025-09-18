#!/bin/bash

# ================================================================
# URL Status Checker
# urlstatustool.sh
#
# Checks if URLs are accessible over HTTP and HTTPS using curl
# Supports custom User-Agent (mobile, desktop, or custom)
# Optional SSL ignore (-k)
# Follows redirects and outputs results to CSV (status, code, final URL).
#
# Usage:
#   ./urlstatustool.sh -i input.csv -o output.csv -u mobile -k
#
# ================================================================

# Default values
input_file="input.csv"
output_file="output.csv"
ignore_ssl=false
user_agent="Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1" # default: mobile

# Preset UAs
ua_mobile="Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
ua_desktop="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36"

# Usage/help function
usage() {
    echo "Usage: $0 [-i input_file] [-o output_file] [-u user_agent] [-k] [-h]"
    echo ""
    echo "Options:"
    echo "  -i FILE     Input CSV file (default: input.csv)"
    echo "  -o FILE     Output CSV file (default: output.csv)"
    echo "  -u AGENT    User-Agent: mobile (default), desktop, custom"
    echo "  -k          Ignore SSL certificate validation"
    echo "  -h          Show this help message"
    exit 1
}

# Parse flags
while getopts "i:o:u:kh" opt; do
    case $opt in
        i) input_file=$OPTARG ;;
        o) output_file=$OPTARG ;;
        u)
            case $OPTARG in
                mobile) user_agent="$ua_mobile" ;;
                desktop) user_agent="$ua_desktop" ;;
                custom) 
                    echo -n "Enter custom User-Agent: "
                    read -r user_agent
                    ;;
                *) 
                    echo "[-] Invalid user-agent option. Use: mobile, desktop, custom"
                    exit 1
                    ;;
            esac
            ;;
        k) ignore_ssl=true ;;
        h) usage ;;
        *) usage ;;
    esac
done

# Check input file exists
if [ ! -f "$input_file" ]; then
    echo "[-] Input file not found: $input_file"
    exit 1
fi

# Prepare curl options
curl_opts=(-s -A "$user_agent" -L -o /dev/null)
$ignore_ssl && curl_opts+=(-k)

# Write CSV header
echo "input,http_status,http_code,http_final_url,https_status,https_code,https_final_url" > "$output_file"

# Function to check URL
check_url() {
    local url=$1
    final_url=$(curl "${curl_opts[@]}" -w "%{url_effective}" "$url")
    final_code=$(curl "${curl_opts[@]}" -w "%{http_code}" "$url")

    if [ "$final_code" -eq 200 ]; then
        echo "UP,$final_code,$final_url"
    elif [ "$final_code" -eq 000 ]; then
        echo "DOWN,$final_code,$final_url"
    else
        echo "UP (ERROR),$final_code,$final_url"
    fi
}

# Process each line from input CSV (skip header)
tail -n +2 "$input_file" | while IFS=, read -r entry; do
    entry=$(echo "$entry" | tr -d ' "\r')
    [ -z "$entry" ] && continue

    # Strip http:// or https:// if present
    stripped=$(echo "$entry" | sed -E 's~^https?://~~')

    http_url="http://$stripped"
    https_url="https://$stripped"

    http_result=$(check_url "$http_url")
    https_result=$(check_url "$https_url")

    echo "\"$stripped\",$http_result,$https_result" >> "$output_file"
    echo "[*] Checked $entry"
done
