# 🧩 k9s-updater.sh

A simple Bash script that checks the latest version of [k9s](https://github.com/derailed/k9s), compares it with the installed version, and builds it from source only if needed.

---

## 🚀 Features

- ✅ Detects the currently installed k9s version  
- 🔍 Fetches the latest release from the GitHub API  
- 💡 Skips download/extraction if already done  
- 🛠 Builds from source using make + go  
- ♻️ Replaces old binary in /usr/local/bin if outdated  
- 📦 Installs the new binary as a system-wide CLI  

---

## 📋 Requirements

This script works on Ubuntu and macOS. You’ll need:

| Tool      | Description                    |
|-----------|--------------------------------|
| bash    | Shell to run the script        |
| wget    | Download files from GitHub     |
| jq      | Parse JSON from GitHub API     |
| make    | Build system to compile source |
| go      | Go compiler to build k9s       |

### ✅ Ubuntu: Install dependencies

```
sudo apt update
sudo apt install -y wget jq build-essential golang
```

### ✅ macOS (with Homebrew)

```
brew install wget jq go
```

---

## 🛠️ Usage

```
chmod +x k9s-updater.sh
./k9s-updater.sh
```

The script will:

1. Check if k9s is installed in the system  
2. Fetch the latest version from GitHub  
3. Compare it to your local version  
4. If outdated:  
   - Remove the old binary from /usr/local/bin  
   - Download the latest source archive  
   - Extract and build it  
   - Install the new binary  

---

## 📂 Example Output

```bash
Installed version: v0.50.7
Latest available version: v0.50.9
🔍 Detected installed version: v0.50.7
♻️ Outdated version detected. Removing /usr/local/bin/k9s...
🛠 Starting build from source...
✅ Build completed successfully
✅ Binary file execs/k9s created
 ____  __ ________       
|    |/  /   __   \______
|       /\____    /  ___/
|    \   \  /    /\___  \
|____|\__ \/____//____  /
         \/           \/ 

Version:    v0.50.9
Commit:     
Date:       2025-07-25T04:23:15Z
✅ Installation completed ✅

```

---

## 🧼 Notes

- This script downloads and builds from source, not prebuilt binaries.  
- It will skip already-completed steps (download, extract, build).  
- If make or go is missing, the script will show clear instructions.  
- If execs/k9s is not created after build — installation will stop.  

---

## 📜 License

MIT — use freely, fork freely.

---

## 👤 Author

Maintained by **me** 😎  
Pull requests and improvements welcome!
