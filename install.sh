#!/usr/bin/env bash

REPO="sakiv/bing-wallpaper-mac"
FOLDER="$HOME/bing-wallpaper-mac"

get_latest_release() {
  curl --silent "https://api.github.com/repos/$REPO/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                                # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                        # Pluck JSON value
}

VERSION=get_latest_release
PACKAGE="//github.com/$REPO/releases/download/$RELEASE/bing-wallpaper-mac.tar.gz"
USER=$(whoami)

if [ -z "$1" ]; then
    read -p "Please enter name to be used [$USER]:" USER
fi

JOB=com.$USER.bing-wallpaper
if [ -z "$2" ]; then
    read -p "Please enter target folder path [$FOLDER]:" FOLDER
fi

# Create directory structure if not exists
mkdir -p "$FOLDER"

# Extract current folder path
CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
echo "Current Folder: $CWD"
# fname="$( basename $USER )";
# echo "File name: $fname"

# Command to create a tar file
# tar --exclude-vcs -cvf bing-wallpaper-mac.tar.gz .

curl -fsSL "$PACKAGE" > "$FOLDER/bundle.tar.gz"
tar -xzf "$FOLDER/bundle.tar.gz" "$FOLDER"
rm "$FOLDER/bundle.tar.gz"

# Replace name in plist file
sed -i "s/{YOUR-NAME}/$USER/g" "$FOLDER/$JOB.plist"
sed -i "s/{TARGET-FOLDER}/$FOLDER/g" "$FOLDER/$JOB.plist"

# Move plist file to LaunchAgents folder
mv "$FOLDER/$JOB.plist" "$HOME/Library/LaunchAgents"

# Generally launchd load these jobs on login but you can load it manually
launchctl load "$HOME/Library/LaunchAgents/$JOB.plist"

# Show the status of the job
launchctl list | grep "$JOB"

exit 0