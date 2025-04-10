#!/system/bin/sh

# Global variables for 
little_cores=0
big_cores=0
little_avg=0
big_avg=0

get_bigLITTLE() {
    local total_clusters=0
    local little_freq_total=0
    local big_freq_total=0

    # --- 1. Collect the maximum frequencies of all CPUs ---
    local all_freqs=$(cat /sys/devices/system/cpu/*/cpufreq/cpuinfo_max_freq 2>/dev/null | xargs)

    # --- 2. Group unique frequencies ---
    local sorted_freqs freq_prev freq count
    sorted_freqs=$(tr ' ' '\n' <<<"$all_freqs" | sort -n)
    freq_prev=""
    for freq in $sorted_freqs; do
        if [ "$freq" != "$freq_prev" ]; then
            count=$(grep -c "^$freq$" <<<"$sorted_freqs")
            eval freq_${total_clusters}=$freq
            eval count_${total_clusters}=$count
            total_clusters=$((total_clusters + 1))
            freq_prev=$freq
        fi
    done

    # --- 3. big.LITTLE classification based on the number of clusters ---
    local i=0 f c f0 f1 c0 c1

    if [ "$total_clusters" -gt 2 ]; then
        while [ "$i" -lt "$total_clusters" ]; do
            eval f=\$freq_$i
            eval c=\$count_$i
            if [ "$i" -lt 2 ]; then
                little_cores=$((little_cores + c))
                little_freq_total=$((little_freq_total + f * c))
            else
                big_cores=$((big_cores + c))
                big_freq_total=$((big_freq_total + f * c))
            fi
            ((i++))
        done

    elif [ "$total_clusters" -eq 2 ]; then
        eval f0=\$freq_0
                    eval c0=\$count_0
        eval f1=\$freq_1
                    eval c1=\$count_1

        if [ "$f0" -lt "$f1" ]; then
            little_cores=$c0
            little_freq_total=$((f0 * c0))
            big_cores=$c1
            big_freq_total=$((f1 * c1))
        else
            little_cores=$c1
            little_freq_total=$((f1 * c1))
            big_cores=$c0
            big_freq_total=$((f0 * c0))
        fi

    elif [ "$total_clusters" -eq 1 ]; then
        eval f0=\$freq_0
                    eval c0=\$count_0
        big_cores=$c0
        big_freq_total=$((f0 * c0))
    fi

    # --- 4. Calculate the average frequency in MHz ---
    little_avg=$((little_cores > 0 ? little_freq_total / little_cores / 1000 : 0))
    big_avg=$((big_cores > 0 ? big_freq_total / big_cores / 1000 : 0))
}

# Call function
get_bigLITTLE

# Output
echo "big core: $big_cores ($big_avg MHz)"
echo "LITTLE core: $little_cores ($little_avg MHz)"
