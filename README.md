# Datasets
# CafeF Data Downloader

A comprehensive bash script to automatically download and extract CafeF trading data files from their public data repository.

## Features

- 🔄 **Multiple Download Modes**: Single file, date range, or recent files
- 📅 **Smart Date Handling**: Automatic date format conversion and validation
- 📦 **Auto-Extraction**: Automatically unzips downloaded files with organized folder structure
- 🎯 **Interactive Mode**: User-friendly menu system with input validation
- ⚡ **Resume Downloads**: Supports resuming interrupted downloads
- 🛡️ **Error Handling**: Robust error checking and user feedback
- 🎨 **Colored Output**: Easy-to-read colored status messages

## Prerequisites

### Required
- `wget` or `curl` (for downloading)
- `bash` shell

### Optional
- `unzip` (for automatic extraction)

### Installation Commands

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install wget unzip
```

**macOS:**
```bash
# wget (curl is pre-installed)
brew install wget
# unzip is usually pre-installed
```

**CentOS/RHEL:**
```bash
sudo yum install wget unzip
```

## Quick Setup

1. **Download the script:**
   ```bash
   # Copy the script content and save as cafef_downloader.sh
   # Or download from your repository
   ```

2. **Make it executable:**
   ```bash
   chmod +x cafef_downloader.sh
   ```

3. **Run the script:**
   ```bash
   ./cafef_downloader.sh
   ```

## Usage

### Interactive Mode (Recommended)

Simply run the script without arguments for the interactive menu:

```bash
./cafef_downloader.sh
```

**Interactive Menu:**
```
=== CafeF Data Downloader - Interactive Mode ===

Do you want to automatically unzip downloaded files? (y/n, default: y): y

Please choose an option:
1) Download single file
2) Download date range
3) Download recent files
4) Toggle auto-unzip (currently: ON)
5) Exit

Enter your choice (1-5): 1
```

### Command Line Usage

#### Single File Download
```bash
# With date prompt
./cafef_downloader.sh single

# Direct download
./cafef_downloader.sh single 20250529
```

#### Date Range Download
```bash
# With date prompts
./cafef_downloader.sh range

# Direct download
./cafef_downloader.sh range 2025-05-25 2025-05-30
```

#### Recent Files Download
```bash
# With day count prompt
./cafef_downloader.sh recent

# Direct download (last 10 days)
./cafef_downloader.sh recent 10
```

### Advanced Usage

#### Disable Auto-Unzip
```bash
# Using environment variable
AUTO_UNZIP=false ./cafef_downloader.sh single 20250529

# Or toggle in interactive mode (option 4)
```

#### Help and Information
```bash
./cafef_downloader.sh help
```
## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `AUTO_UNZIP` | `true` | Enable/disable automatic unzipping |

### Script Configuration

You can modify these variables at the top of the script:

```bash
BASE_URL="https://cafef1.mediacdn.vn/data/ami_data"
FILE_PREFIX="CafeF.SolieuGD.Upto"
DOWNLOAD_DIR="./cafef_data"
EXTRACT_DIR="./cafef_data/extracted"
AUTO_UNZIP=true
```

## Command Reference

### All Commands

```bash
# Interactive mode (default)
./cafef_downloader.sh
./cafef_downloader.sh interactive
./cafef_downloader.sh menu

# Single file commands
./cafef_downloader.sh single                    # Prompts for date
./cafef_downloader.sh single 20250529          # Direct download

# Date range commands
./cafef_downloader.sh range                     # Prompts for dates
./cafef_downloader.sh range 2025-05-25 2025-05-30  # Direct download

# Recent files commands
./cafef_downloader.sh recent                    # Prompts for day count
./cafef_downloader.sh recent 7                 # Last 7 days
./cafef_downloader.sh recent 30                # Last 30 days

# Help
./cafef_downloader.sh help
```

### Date Formats

- **Single file**: `YYYYMMDD` (e.g., `20250529`)
- **Date range**: `YYYY-MM-DD` (e.g., `2025-05-29`)

## Troubleshooting

### Common Issues

1. **"Permission denied" error:**
   ```bash
   chmod +x cafef_downloader.sh
   ```

2. **"wget: command not found":**
   ```bash
   # Install wget or use curl (automatically detected)
   sudo apt install wget
   ```

3. **"unzip: command not found":**
   ```bash
   # Install unzip for automatic extraction
   sudo apt install unzip
   ```

4. **Download fails with 404 error:**
   - Check if the date exists (trading days only)
   - Verify the date format
   - Some files might not be available for weekends/holidays

### Debug Mode

For debugging, you can run the script with verbose output:

```bash
bash -x ./cafef_downloader.sh single 20250529
```

