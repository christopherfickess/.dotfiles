#!/bin/bash

function cleanup_old_bash_processes() {
    for arg in "$@"; do
        case $arg in
            --help|-h)
                echo -e "${MAGENTA}Cleans up old bash processes running longer than a specified time.${NC}"
                echo "Usage: cleanup_old_bash [--days=N] [--hours=N]"
                echo "  --days=N    Number of days old processes to kill (default 2)"
                echo "  --hours=N   Number of hours old processes to kill"
                echo "  --help/-h   Show this help message"
                echo
                echo -e "${MAGENTA}Examples:${NC}"
                echo "  cleanup_old_bash --days=3"
                echo "  cleanup_old_bash --hours=12"
                return
                ;;
            --days=*|-d=*)
                DAYS="${arg#*=}"
                ;;
            --hours=*|-H=*)
                HOURS="${arg#*=}"
                # Convert hours to fractional days
                DAYS=$(awk "BEGIN {printf \"%.4f\", $HOURS/24}")
                ;;
            *)
                ;;
        esac
    done

    echo -e "${GREEN}Cleaning up bash processes older than ${DAYS} days...${NC}"

    powershell.exe -Command "
    \$cutoff = (Get-Date).AddDays(-$DAYS)
    Get-Process bash -ErrorAction SilentlyContinue | 
        Where-Object { \$_.StartTime -lt \$cutoff } |
        ForEach-Object { 
            Write-Host 'Killing old bash process:' \$_.Id 'started at' \$_.StartTime
            Stop-Process -Id \$_.Id -Force
        }
    "
}

function count_terminals_open() {
    powershell.exe -Command "(Get-Process bash -ErrorAction SilentlyContinue).Count"
}

function show_terminals_time() {
    powershell.exe -Command "Get-Process bash | Format-Table Id,StartTime,Path"
}