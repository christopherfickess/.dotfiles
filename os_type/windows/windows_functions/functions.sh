#!/bin/bash

function cleanup_old_bash_processes() {
    local __time_to_live__=2  # Default to 2 days
    
    for arg in "$@"; do
        case $arg in
            --help|-h)
                echo -e "${MAGENTA}Cleans up old bash processes running longer than a specified time.${NC}"
                echo "Usage: cleanup_old_bash_processes [ -d=N | --days=N ] \
                    [ -H=N | --hours=N ] \
                    [ -m=N | --minutes=N ] \
                    [ -h | --help ]"
                echo "  -d | --days=N    Number of days old processes to kill (default 2)"
                echo "  -H | --hours=N   Number of hours old processes to kill"
                echo "  -m | --minutes=N Number of minutes old processes to kill"
                echo "  -h | --help      Show this help message"
                echo
                echo -e "${MAGENTA}Examples:${NC}"
                echo "  cleanup_old_bash_processes --days=3"
                echo "  cleanup_old_bash_processes --hours=12"
                echo "  cleanup_old_bash_processes --minutes=12"
                return
                ;;
            --days=*|-d=*)
                __time_to_live__="${arg#*=}"
                ;;
            --hours=*|-H=*)
                HOURS="${arg#*=}"
                # Convert hours to fractional days
                __time_to_live__=$(awk "BEGIN {printf \"%.4f\", $HOURS/24}")
                ;;
            --minutes=*|-m=*)
                MINUTES="${arg#*=}"
                # Convert minutes to fractional days
                __time_to_live__=$(awk "BEGIN {printf \"%.6f\", $MINUTES/(24*60)}")
                ;;
            *)  
                ;;
        esac
    done

    echo -e "${GREEN}Cleaning up bash processes older than ${__time_to_live__} days...${NC}"

    powershell.exe -Command "
    \$cutoff = (Get-Date).AddDays(-$__time_to_live__)
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