#!/bin/bash

# Make a folder to save the reports
mkdir -p trivy-reports

# Loop through each image
for image in $(docker images --format "{{.Repository}}:{{.Tag}}"); do
    # Replace / and : with _ to make a valid filename
    safe_name=$(echo "$image" | sed 's/[/:]/_/g')
    echo "Scanning $image..."
    trivy image "$image" > "trivy-reports/${safe_name}.txt"
done

echo "✅ Scanning complete. Reports are in trivy-reports/ folder."
