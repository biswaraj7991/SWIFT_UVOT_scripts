#!/bin/bash

# File containing directories to process
path_file="image_paths.txt"

# List of file patterns to check
patterns=("*uu_sk.img.gz" "*bb_sk.img.gz" "*vv_sk.img.gz" "*m2_sk.img.gz" "*w1_sk.img.gz" "*w2_sk.img.gz")

# Loop through each line in UVOT_extraction_paths
while IFS= read -r search_dir; do

    # Output file to store the list of existing files in each directory
    output_file="$search_dir/present_filters.txt"
    
    # Clear output file if it exists
    > "$output_file"
    
    # Check each pattern and list the files that exist in the current search_dir
    for pattern in "${patterns[@]}"; do
        for file in "$search_dir"/$pattern; do
            if [[ -e "$file" ]]; then
                echo "$file" >> "$output_file"
            fi
        done
    done
    
    # Check if output file has entries
    if [[ -s "$output_file" ]]; then
        echo "The following files are present in $search_dir:"
        cat "$output_file"
    else
        echo "No matching files found in $search_dir."
        continue  # Skip to the next directory in the path file
    fi
    
    # Loop over each file listed in the output file
    while IFS= read -r line; do
        # Navigate to the directory of the file
        cd "$(dirname "$line")" || continue
        cp /home/palit/work/project_2/Mrk590/swift_XRT/all_swift/src.reg /home/palit/work/project_2/Mrk590/swift_XRT/all_swift/bkg.reg .

        filename=$(basename "$line")
        
        echo "Processing file: $filename"
        
        # Extract base name and suffix
        base_name=$(basename "$filename" _sk.img.gz)
        suffix=${base_name: -2}  # Get the last two letters
        
        # Check if the file exists before processing
        if [[ -f "$filename" ]]; then
            # Display a large notification for processing
            figlet "Processing: $filename"
            
            # Perform UVOT data processing commands
            uvotimsum infile="$filename" outfile="Usum.fits" clobber="yes"
            uvotsource "$filename"+1 src.reg bkg.reg 3 "${suffix}.fits" clobber="yes"
            uvot2pha "$filename"+1 src.reg bkg.reg "src_${suffix}.pha" "bkg_${suffix}.pha" CALDB clobber="yes"
        fi
    done < "$output_file"

done < "$path_file"

