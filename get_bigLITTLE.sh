#!/system/bin/sh

# Global variables for core counts and average frequencies
little_cores=0
big_cores=0
little_cores_freq=0
big_cores_freq=0

# Function to detect and classify CPU cores into LITTLE and BIG clusters
detect_cpu_clusters() {
    local total_clusters=0
    local little_total_freq=0
    local big_total_freq=0
    local cpu_frequencies sorted_frequencies last_frequency current_frequency core_count cluster_index

    # Variables to store frequency and count for each cluster (using dynamic variables)
    local freq_0 freq_1 freq_2 freq_3 count_0 count_1 count_2 count_3

    # Read CPU frequency information from sysfs
    cpu_frequencies=$(cat /sys/devices/system/cpu/cpu*/cpufreq/cpuinfo_max_freq 2>/dev/null | xargs)

    # Check if frequency data is available
    if [ -z "$cpu_frequencies" ]; then
        echo "Error: No CPU frequency information found."
        return 1
    fi

    # Sort frequencies numerically to group identical values
    sorted_frequencies=$(echo "$cpu_frequencies" | tr ' ' '\n' | sort -n)

    # Count unique frequencies and their occurrences
    last_frequency=""
    for current_frequency in $sorted_frequencies; do
        # Skip duplicate frequencies
        [ "$current_frequency" = "$last_frequency" ] && continue

        # Count how many cores have this frequency
        core_count=$(echo "$sorted_frequencies" | grep -c "^$current_frequency$")

        # Store frequency and count for this cluster using dynamic variables
        eval "freq_$total_clusters=$current_frequency"
        eval "count_$total_clusters=$core_count"

        last_frequency=$current_frequency
        total_clusters=$((total_clusters + 1))
    done

    # Classify clusters as LITTLE or BIG cores
    cluster_index=0
    while [ "$cluster_index" -lt "$total_clusters" ]; do
        # Get frequency and core count using dynamic variables
        eval "current_frequency=\$freq_$cluster_index"
        eval "core_count=\$count_$cluster_index"

        # Classification logic: Single cluster: all cores are BIG, Two clusters: first is LITTLE, second is BIG, Multiple clusters: first two are LITTLE, rest are BIG
        if [ "$total_clusters" -eq 1 ] || { [ "$total_clusters" -eq 2 ] && [ "$cluster_index" -eq 1 ]; } || [ "$cluster_index" -ge 2 ]; then
            # Classify as BIG cores
            big_cores=$((big_cores + core_count))
            big_total_freq=$((big_total_freq + current_frequency * core_count))
        else
            # Classify as LITTLE cores
            little_cores=$((little_cores + core_count))
            little_total_freq=$((little_total_freq + current_frequency * core_count))
        fi

        cluster_index=$((cluster_index + 1))
    done

    # Calculate average frequencies in MHz
    if [ "$little_cores" -gt 0 ]; then
        little_cores_freq=$((little_total_freq / little_cores / 1000))
    fi

    if [ "$big_cores" -gt 0 ]; then
        big_cores_freq=$((big_total_freq / big_cores / 1000))
    fi

    return 0
}

# Function to display results
display_results() {
    echo "LITTLE cores: $little_cores cores, average frequency: ${little_cores_freq}MHz"
    echo "BIG cores:    $big_cores cores, average frequency: ${big_cores_freq}MHz"
}

# Main execution
main() {
    if detect_cpu_clusters; then
        display_results
    else
        echo "Failed to detect CPU clusters."
        exit 1
    fi
}

# Execute main function
main
