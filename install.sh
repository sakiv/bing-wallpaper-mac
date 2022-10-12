#!/usr/bin/env bash

if [ -z "$1" ]; then
    echo "Usage: ./install {yourname} [target directory path]"
    exit 1
fi

lp="//github.com/sakiv/bing-wallpaper-mac/releases/download/v1.0.1/bing-wallpaper-mac.tar.gz"
jn=com.$1.bing-wallpaper
tf=$2
if [ -z "$2" ]; then
    tf="~/bing-wallpaper-mac"
    mkdir -p "$tf"
fi

# Extract current folder path
cf="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
echo "Current Folder: $cf"
# fname="$( basename $1 )";
# echo "File name: $fname"

# Command to create a tar file
# tar --exclude-vcs -cvf bing-wallpaper-mac.tar.gz .

curl -fsSL "$lp" > "$tf/bundle.tar.gz"
tar -xzf "$tf/bundle.tar.gz" "$tf"

# Move plist file to LaunchAgents folder
mv "$tf/$jn.plist" "$HOME/Library/LaunchAgents"

# Generally launchd load these jobs on login but you can load it manually
launchctl load "$HOME/Library/LaunchAgents/$jn.plist"

# Show the status of the job
launchctl list | grep "$jn"

exit 0