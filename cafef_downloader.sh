#!/bin/bash

# CafeF Data Downloader Script
# Downloads trading data files from CafeF based on date range

# Configuration
BASE_URL="https://cafef1.mediacdn.vn/data/ami_data"
FILE_PREFIX="CafeF.SolieuGD.Upto"
DOWNLOAD_DIR="./cafef_data"
EXTRACT_DIR="./cafef_data/extracted"
AUTO_UNZIP=true  # Set to false to disable automatic unzipping

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to validate date format
validate_date() {
    if [[ $1 =~ ^[0-9]{8}$ ]]; then
        return 0
    else
        return 1
    fi
}

# Function to convert date format (YYYYMMDD to DDMMYYYY)
convert_date() {
    local input_date=$1
    local year=${input_date:0:4}
    local month=${input_date:4:2}
    local day=${input_date:6:2}
    echo "${day}${month}${year}"
}

# Function to download a single file
download_file() {
    local date_folder=$1
    local date_converted=$2
    local url="${BASE_URL}/${date_folder}/${FILE_PREFIX}${date_converted}.zip"
    local filename="${FILE_PREFIX}${date_converted}.zip"
    local full_path="$DOWNLOAD_DIR/$filename"
    
    print_status "Downloading: $filename"
    
    # Create download directory if it doesn't exist
    mkdir -p "$DOWNLOAD_DIR"
    
    # Download with wget (fallback to curl if wget not available)
    if command -v wget &> /dev/null; then
        wget --progress=bar --continue -P "$DOWNLOAD_DIR" "$url"
    elif command -v curl &> /dev/null; then
        curl -C - --progress-bar -o "$full_path" "$url"
    else
        print_error "Neither wget nor curl is available. Please install one of them."
        return 1
    fi
    
    # Check if download was successful
    if [ $? -eq 0 ]; then
        print_status "Successfully downloaded: $filename"
        
        # Unzip if enabled
        if [ "$AUTO_UNZIP" = "true" ]; then
            # Create date-specific extraction directory
            local extract_subdir="$EXTRACT_DIR/$date_converted"
            unzip_file "$full_path" "$extract_subdir"
        fi
        
        return 0
    else
        print_error "Failed to download: $filename"
        return 1
    fi
}

# Function to generate date range
generate_date_range() {
    local start_date=$1
    local end_date=$2
    
    # Convert to seconds since epoch for easy iteration
    local start_epoch=$(date -d "$start_date" +%s 2>/dev/null)
    local end_epoch=$(date -d "$end_date" +%s 2>/dev/null)
    
    # Check if date conversion was successful
    if [ $? -ne 0 ]; then
        print_error "Invalid date format. Use YYYY-MM-DD"
        return 1
    fi
    
    local current_epoch=$start_epoch
    local dates=()
    
    while [ $current_epoch -le $end_epoch ]; do
        local current_date=$(date -d "@$current_epoch" +%Y%m%d)
        dates+=("$current_date")
        current_epoch=$((current_epoch + 86400)) # Add 24 hours
    done
    
    echo "${dates[@]}"
}

# Function to get user input for date
get_user_date_input() {
    local prompt_msg="$1"
    local date_format="$2"
    local date_input
    
    while true; do
        echo -n "$prompt_msg: "
        read date_input
        
        if [ "$date_format" = "YYYYMMDD" ]; then
            if validate_date "$date_input"; then
                echo "$date_input"
                break
            else
                print_error "Invalid date format. Please use YYYYMMDD (e.g., 20250529)"
            fi
        elif [ "$date_format" = "YYYY-MM-DD" ]; then
            # Validate YYYY-MM-DD format
            if [[ $date_input =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
                # Test if date is valid by trying to convert it
                if date -d "$date_input" &> /dev/null; then
                    echo "$date_input"
                    break
                else
                    print_error "Invalid date. Please use YYYY-MM-DD format (e.g., 2025-05-29)"
                fi
            else
                print_error "Invalid date format. Please use YYYY-MM-DD (e.g., 2025-05-29)"
            fi
        fi
    done
}

# Function to unzip a file
unzip_file() {
    local zip_file="$1"
    local extract_to="$2"
    local filename=$(basename "$zip_file")
    
    # Check if unzip command is available
    if ! command -v unzip &> /dev/null; then
        print_warning "unzip command not found. Skipping extraction for $filename"
        print_warning "Please install unzip package to enable automatic extraction"
        return 1
    fi
    
    # Check if file exists
    if [ ! -f "$zip_file" ]; then
        print_error "ZIP file not found: $zip_file"
        return 1
    fi
    
    # Create extraction directory if it doesn't exist
    mkdir -p "$extract_to"
    
    print_status "Extracting: $filename"
    
    # Extract with overwrite and create directory structure
    if unzip -o "$zip_file" -d "$extract_to" &> /dev/null; then
        print_status "Successfully extracted: $filename"
        
        # List extracted files
        print_status "Extracted files:"
        ls -la "$extract_to" | grep -v "^total" | tail -n +2 | while read line; do
            echo "  $line"
        done
        
        return 0
    else
        print_error "Failed to extract: $filename"
        return 1
    fi
}

# Function to get user preference for unzipping
get_unzip_preference() {
    local preference
    
    while true; do
        echo -n "Do you want to automatically unzip downloaded files? (y/n, default: y): "
        read preference
        
        case "${preference:-y}" in
            [Yy]|[Yy][Ee][Ss])
                echo "true"
                break
                ;;
            [Nn]|[Nn][Oo])
                echo "false"
                break
                ;;
            *)
                print_error "Please enter 'y' for yes or 'n' for no"
                ;;
        esac
    done
}
get_user_days_input() {
    local days_input
    
    while true; do
        echo -n "Enter number of days (default: 7): "
        read days_input
        
        # If empty, use default
        if [ -z "$days_input" ]; then
            echo "7"
            break
        fi
        
        # Check if it's a positive number
        if [[ $days_input =~ ^[1-9][0-9]*$ ]]; then
            echo "$days_input"
            break
        else
            print_error "Please enter a positive number"
        fi
    done
}

# Interactive menu function
show_interactive_menu() {
    echo "=== CafeF Data Downloader - Interactive Mode ==="
    echo
    
    # Ask for unzip preference if AUTO_UNZIP is not set
    if [ -z "$UNZIP_PREFERENCE_SET" ]; then
        AUTO_UNZIP=$(get_unzip_preference)
        UNZIP_PREFERENCE_SET=true
        echo
    fi
    
    echo "Please choose an option:"
    echo "1) Download single file"
    echo "2) Download date range"
    echo "3) Download recent files"
    echo "4) Toggle auto-unzip (currently: $([ "$AUTO_UNZIP" = "true" ] && echo "ON" || echo "OFF"))"
    echo "5) Exit"
    echo
    
    while true; do
        echo -n "Enter your choice (1-5): "
        read choice
        
        case $choice in
            1)
                echo
                print_status "Single file download selected"
                date_input=$(get_user_date_input "Enter date (YYYYMMDD, e.g., 20250529)" "YYYYMMDD")
                date_folder="$date_input"
                date_converted=$(convert_date "$date_input")
                download_file "$date_folder" "$date_converted"
                break
                ;;
            2)
                echo
                print_status "Date range download selected"
                start_date=$(get_user_date_input "Enter start date (YYYY-MM-DD, e.g., 2025-05-25)" "YYYY-MM-DD")
                end_date=$(get_user_date_input "Enter end date (YYYY-MM-DD, e.g., 2025-05-30)" "YYYY-MM-DD")
                
                print_status "Generating date range from $start_date to $end_date"
                dates=$(generate_date_range "$start_date" "$end_date")
                
                if [ $? -ne 0 ]; then
                    exit 1
                fi
                
                success_count=0
                total_count=0
                
                for date in $dates; do
                    total_count=$((total_count + 1))
                    date_converted=$(convert_date "$date")
                    
                    if download_file "$date" "$date_converted"; then
                        success_count=$((success_count + 1))
                    fi
                    
                    sleep 1
                done
                
                echo
                print_status "Download summary: $success_count/$total_count files downloaded successfully"
                break
                ;;
            3)
                echo
                print_status "Recent files download selected"
                days=$(get_user_days_input)
                print_status "Downloading last $days days of data"
                
                success_count=0
                total_count=0
                
                for i in $(seq 0 $((days-1))); do
                    total_count=$((total_count + 1))
                    date=$(date -d "$i days ago" +%Y%m%d)
                    date_converted=$(convert_date "$date")
                    
                    if download_file "$date" "$date_converted"; then
                        success_count=$((success_count + 1))
                    fi
                    
                    sleep 1
                done
                
                echo
                print_status "Download summary: $success_count/$total_count files downloaded successfully"
                break
                ;;
            4)
                if [ "$AUTO_UNZIP" = "true" ]; then
                    AUTO_UNZIP="false"
                    print_status "Auto-unzip disabled"
                else
                    AUTO_UNZIP="true"
                    print_status "Auto-unzip enabled"
                fi
                echo
                echo "Please choose an option:"
                echo "1) Download single file"
                echo "2) Download date range"
                echo "3) Download recent files"
                echo "4) Toggle auto-unzip (currently: $([ "$AUTO_UNZIP" = "true" ] && echo "ON" || echo "OFF"))"
                echo "5) Exit"
                echo
                ;;
            5)
                print_status "Exiting..."
                exit 0
                ;;
            *)
                print_error "Invalid choice. Please enter 1, 2, 3, 4, or 5."
                ;;
        esac
    done
}

# Main function
main() {
    echo "=== CafeF Data Downloader ==="
    echo
    
    # If no arguments provided, show interactive menu
    if [ $# -eq 0 ]; then
        show_interactive_menu
        exit 0
    fi
    
    case "${1:-help}" in
        "interactive"|"menu")
            show_interactive_menu
            ;;
            
        "single")
            if [ -z "$2" ]; then
                print_status "Interactive mode: Single file download"
                date_input=$(get_user_date_input "Enter date (YYYYMMDD, e.g., 20250529)" "YYYYMMDD")
                date_folder="$date_input"
                date_converted=$(convert_date "$date_input")
                download_file "$date_folder" "$date_converted"
            else
                if ! validate_date "$2"; then
                    print_error "Invalid date format. Use YYYYMMDD (e.g., 20250529)"
                    exit 1
                fi
                
                date_folder="$2"
                date_converted=$(convert_date "$2")
                download_file "$date_folder" "$date_converted"
            fi
            ;;
            
        "range")
            if [ -z "$2" ] || [ -z "$3" ]; then
                print_status "Interactive mode: Date range download"
                start_date=$(get_user_date_input "Enter start date (YYYY-MM-DD, e.g., 2025-05-25)" "YYYY-MM-DD")
                end_date=$(get_user_date_input "Enter end date (YYYY-MM-DD, e.g., 2025-05-30)" "YYYY-MM-DD")
            else
                start_date="$2"
                end_date="$3"
            fi
            
            print_status "Generating date range from $start_date to $end_date"
            dates=$(generate_date_range "$start_date" "$end_date")
            
            if [ $? -ne 0 ]; then
                exit 1
            fi
            
            success_count=0
            total_count=0
            
            for date in $dates; do
                total_count=$((total_count + 1))
                date_converted=$(convert_date "$date")
                
                if download_file "$date" "$date_converted"; then
                    success_count=$((success_count + 1))
                fi
                
                sleep 1
            done
            
            echo
            print_status "Download summary: $success_count/$total_count files downloaded successfully"
            ;;
            
        "recent")
            if [ -z "$2" ]; then
                print_status "Interactive mode: Recent files download"
                days=$(get_user_days_input)
            else
                days="$2"
            fi
            
            print_status "Downloading last $days days of data"
            
            success_count=0
            total_count=0
            
            for i in $(seq 0 $((days-1))); do
                total_count=$((total_count + 1))
                date=$(date -d "$i days ago" +%Y%m%d)
                date_converted=$(convert_date "$date")
                
                if download_file "$date" "$date_converted"; then
                    success_count=$((success_count + 1))
                fi
                
                sleep 1
            done
            
            echo
            print_status "Download summary: $success_count/$total_count files downloaded successfully"
            ;;
            
        "help"|*)
            echo "Usage: $0 [command] [options]"
            echo
            echo "Commands:"
            echo "  (no arguments)            Interactive mode with menu"
            echo "  interactive/menu          Show interactive menu"
            echo "  single [YYYYMMDD]         Download single file (prompts if date not provided)"
            echo "  range [YYYY-MM-DD] [YYYY-MM-DD] Download date range (prompts if dates not provided)"
            echo "  recent [days]             Download recent files (prompts if days not provided)"
            echo "  help                      Show this help message"
            echo
            echo "Examples:"
            echo "  $0                        # Interactive mode"
            echo "  $0 single                 # Prompts for date"
            echo "  $0 single 20250529        # Direct download"
            echo "  $0 range                  # Prompts for dates"
            echo "  $0 range 2025-05-25 2025-05-30  # Direct download"
            echo "  $0 recent                 # Prompts for number of days"
            echo "  $0 recent 10              # Download last 10 days"
            echo
            echo "Files will be downloaded to: $DOWNLOAD_DIR"
            ;;
    esac
}

# Run main function with all arguments
main "$@"