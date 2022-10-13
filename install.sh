#!/usr/bin/env bash

REPO="sakiv/bing-wallpaper-mac"
FOLDER="$HOME/bing-wallpaper-mac"

__get_latest_release() {
    echo Retriving latest release version... >&2
    curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
        grep '"tag_name":' |                                                # Get tag line
        sed -E 's/.*"([^"]+)".*/\1/'                                        # Pluck JSON value
}

USER=$(whoami)
if [ -z "$1" ]; then
    read -p "Please enter name to be used [$USER]:" IN_USER
    USER=${IN_USER:-$USER}
    # echo $IN_USER
    # echo $USER
fi

if [ -z "$2" ]; then
    read -p "Please enter target folder path [$FOLDER]:" IN_FOLDER
    FOLDER=${IN_FOLDER:-$FOLDER}
    # echo $IN_FOLDER
    # echo $FOLDER
fi

VERSION=$(__get_latest_release $REPO)
echo "Deploying latest version: $VERSION"
PACKAGE="https://github.com/$REPO/releases/download/$VERSION/bing-wallpaper-mac.tar.gz"
JOB=com.$USER.bing-wallpaper

# echo $VERSION
# echo $PACKAGE
# echo $JOB
# exit 0

# Extract current folder path
CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
# echo "Current Folder: $CWD"
fname="$( basename $USER )";
# echo "File name: $fname"

# Create directory structure if not exists
mkdir -p "$FOLDER"
# echo $FOLDER

echo "Fetching latest package - $PACKAGE"
curl -fsSL "$PACKAGE" > "$FOLDER/bundle.tar.gz"

# Command to create a tar file
# tar --exclude-vcs --exclude=".DS_Store" --exclude="*.tar.gz" --exclude="install.sh" -cvf bing-wallpaper-mac.tar.gz .

# echo "Deploying at $FOLDER"
tar -xzf "$FOLDER/bundle.tar.gz" -C "$FOLDER"
rm "$FOLDER/bundle.tar.gz"
# echo "$FOLDER/com.yourname.bing-wallpaper.plist"
# echo "$FOLDER/$JOB.plist"
mv "$FOLDER/com.yourname.bing-wallpaper.plist" "$FOLDER/$JOB.plist"

# Replace name in plist file
sed -i '' "s~{YOUR-NAME}~$USER~g" "$FOLDER/$JOB.plist"
sed -i '' "s~{TARGET-FOLDER}~$FOLDER~g" "$FOLDER/$JOB.plist"

echo "Registering with your OS..."
# Move plist file to LaunchAgents folder
mv "$FOLDER/$JOB.plist" "$HOME/Library/LaunchAgents"

# Generally launchd load these jobs on login but you can load it manually
launchctl load "$HOME/Library/LaunchAgents/$JOB.plist"

if ! command -v sqlite3 &> /dev/null
then
    echo "Warning: We were not able to set Desktop Wallpaper systematically, please perform final step to complete installation - https://github.com/sakiv/bing-wallpaper-mac#set-desktop-wallpaper"
else
    sqlite3 "$HOME/Library/Application\ Support/Dock/desktoppicture.db" "update data set value='$HOME/Pictures/Bing-Wallpapers'"
fi

# Show the status of the job
# launchctl list | grep "$JOB"

echo "Successfully completed deployment"
echo "Deployed at $FOLDER"
exit 0