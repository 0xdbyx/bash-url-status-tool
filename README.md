# Bash URL Status Tool

A Bash script to check the HTTP and HTTPS status of a list of URLs using `curl`.  
Supports custom User-Agent, optional SSL certificate validation ignore, and follows redirects. Outputs results in a CSV file.

## Features

- Check both HTTP and HTTPS for each URL
- Custom User-Agent options: `mobile`, `desktop`, or a `custom` string
- Optional SSL ignore (`-k`) for sites with invalid certificates
- Follows redirects and records the final URL
- Outputs results in CSV format with:
  - Input URL
  - Status (UP / DOWN / UP (ERROR))
  - HTTP code
  - Final resolved URL

## Usage

```bash
# Default: input.csv → output.csv, mobile UA, SSL validated
./urlstatustool.sh

# Specify input and output files
./urlstatustool.sh -i urls.csv -o results.csv

# Use desktop User-Agent
./urlstatustool.sh -u desktop

# Provide custom User-Agent
./urlstatustool.sh -u custom

# Ignore SSL certificate errors
./urlstatustool.sh -k
```

## CSV Input Format

url
example.com
http://test.com/path
https://example.com

## CSV Output Format

input,http_status,http_code,http_final_url,https_status,https_code,https_final_url
example.com,UP,000,http://example.com,UP,200,https://example.com
