#!/usr/bin/env bash

set -euo pipefail

# Ensure required directories exist
if [[ ! -d "proto" ]]; then
  echo "Directory 'proto' not found!" >&2
  exit 1
fi

# Find all .proto files in the proto directory
for pbfile in proto/*.proto; do
  # Skip if no .proto files are found
  [[ -e "$pbfile" ]] || { echo "No .proto files found in proto/."; break; }

  mod="${pbfile##*/}"
  mod="${mod%%.proto}"

  outdir="./pkg/pb/${mod}pb"
  mkdir -p "$outdir"

  protoc -I proto/ \
    -I "${GOPATH:-}/src" \
    -I /usr/local/include \
    -I "${GOPATH:-}/src/github.com/envoyproxy/protoc-gen-validate" \
    --go_out=plugins=grpc:"$outdir" --go_opt=paths=source_relative \
    --validate_out="lang=go,paths=source_relative:$outdir" \
    "$pbfile"
done
