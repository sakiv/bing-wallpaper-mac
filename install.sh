#!/usr/bin/env bash

REPO="sakiv/bing-wallpaper-mac"
DEFAULT_FOLDER="$HOME/bing-wallpaper-mac"
DEFAULT_USER=$(whoami)

__get_latest_release() {
    echo Retriving latest release version... >&2
    curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
        grep '"tag_name":' |                                                # Get tag line
        sed -E 's/.*"([^"]+)".*/\1/'                                        # Pluck JSON value
}

for arg; do # default for a for loop is to iterate over "$@"
  case $arg in
    '--debug') 
        echo "Debug mode enabled"
        DEBUG=1
        set -x 
        ;;
    'user='*) USERNAME=${arg#*=} ;;
    'folder='*) FOLDER=${arg#*=} ;;
  esac
done

if [ -z "$USERNAME" ]; then
    read -p "Please enter name to be used [$DEFAULT_USER]:" IN_USER
    USERNAME=${IN_USER:-$DEFAULT_USER}
    # echo $IN_USER
    # echo $USERNAME
fi

if [ -z "$FOLDER" ]; then
    read -p "Please enter target folder path [$DEFAULT_FOLDER]:" IN_FOLDER
    FOLDER=${IN_FOLDER:-$DEFAULT_FOLDER}
    # echo $IN_FOLDER
    # echo $FOLDER
fi

# Extract current folder path
CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
# echo "Current Folder: $CWD"
fname="$( basename $USERNAME )";
# echo "File name: $fname"

# Create directory structure if not exists
mkdir -p "$FOLDER"
# echo $FOLDER

if [ -z "$DEBUG" ]; then
    VERSION=$(__get_latest_release $REPO)
    echo "Deploying latest version: $VERSION"
    PACKAGE="https://github.com/$REPO/releases/download/$VERSION/bing-wallpaper-mac.tar.gz"
    JOB=com.$USERNAME.bing-wallpaper

    # echo $VERSION
    # echo $PACKAGE
    # echo $JOB
    # exit 0

    echo "Fetching latest package - $PACKAGE"
    curl -fsSL "$PACKAGE" > "$FOLDER/bundle.tar.gz"

    # Command to create a tar file
    # tar --exclude-vcs --exclude=".DS_Store" --exclude=".github" --exclude="assets" --exclude="*.tar.gz" --exclude="install.sh" -cvf bing-wallpaper-mac.tar.gz .

    # echo "Deploying at $FOLDER"
    tar -xzf "$FOLDER/bundle.tar.gz" -C "$FOLDER"
    rm "$FOLDER/bundle.tar.gz"    
else 
    echo "Deploying code from local folder: [$(PWD)]"
    tar --exclude-vcs --exclude=".DS_Store" --exclude=".github" --exclude="assets" --exclude="*.tar.gz" --exclude="install.sh" -cvf bing-wallpaper-mac.tar.gz .
    tar -xzf bing-wallpaper-mac.tar.gz -C "$FOLDER"
    JOB=com.$USERNAME.bing-wallpaper
fi

# echo "$FOLDER/com.yourname.bing-wallpaper.plist"
# echo "$FOLDER/$JOB.plist"
mv "$FOLDER/com.yourname.bing-wallpaper.plist" "$FOLDER/$JOB.plist"

# Replace name in plist file
sed -i '' "s~{YOUR-NAME}~$USERNAME~g" "$FOLDER/$JOB.plist"
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
    query="insert into data select * from ("
    query="${query} select ('~/Pictures/Bing-Wallpapers') as new_value"
    query="${query} union"
    query="${query} select ('3,600') as new_value"
    query="${query} union"
    query="${query} select ('0') as new_value"
    query="${query} union"
    query="${query} select ('1') as new_value"
    query="${query}) where NOT EXISTS (select value from data where value = new_value)"

    sqlite3 "$HOME/Library/Application Support/Dock/desktoppicture.db" $query
fi

# Show the status of the job
# launchctl list | grep "$JOB"

echo "Successfully completed deployment"
echo "Deployed at $FOLDER"
exit 0