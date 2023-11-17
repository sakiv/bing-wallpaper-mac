#!/usr/bin/env bash
 
PICTURE_DIR="$HOME/Pictures/Bing-Wallpapers"
 
mkdir -p $PICTURE_DIR

urls=( $(curl -sSL https://www.bing.com | \
    grep -Eo 'g_img={url:\s*".*?"' | \
	sed -e 's/g_img={url:\s*"//g' | \
	sed -e 's/"//g' | \
	sed -e 's/\\\u0026/\&/g' ) )

if [ "$urls" = "" ]
then   
	urls=( $(curl -sSL https://www.bing.com | \
    	grep -Eo 'g_img={url:\s*".*?"' | \
		sed -e 's/g_img={url:\s*"\([^"]*\)".*/http:\/\/bing.com\1/' | \
		sed -e 's/\\//g' | \
		sed -e 's/\\\u0026/\&/g' ) )
fi

if [ "$urls" = "" ]
then	
	urls=( $(curl -sSL https://www.bing.com | \
    	grep -Eo 'background-image: url\(.*\.jpg\)' | \
		sed -e 's/background-image: url(//g' | \
		sed -e 's/)//g' ) )
fi

if [ "$urls" = "" ]
then 
    urls=( $(curl -sSL https://www.bing.com | \
        grep -Eo '<link rel="preload" href=".*&' | \
        sed -e 's/<link rel="preload" href="//g' | \
        sed -e 's/&.*//g' ) )
fi

if [ "$urls" = "" ]
then 
    urls=( $(curl -sSL https://www.bing.com | \
        grep -Eo '<meta property="og:image" content=".*&' | \
        sed -e 's/<meta property="og:image" content="//g' | \
        sed -e 's/&.*//g' ) )
fi

if [ "$urls" != "" ]
then

    if [[ $urls = //* ]]
    then
        urls="http:$urls"
    elif [[ $urls != http* ]]
    then
        urls="http://www.bing.com$urls"
    fi
 
    today=$(date +%Y%m%d)
    file_ext=$(echo $urls|sed -e "s/.*\/\(.*\)/\1/"|sed -e "s/.*\.//g")

    # # Remove files older than 6 days
    # find $PICTURE_DIR/*.$file_ext -type f -mtime +6 -print0 | xargs -r0 echo --

    # Remove all files in the directory
    rm -Rf $PICTURE_DIR/*.*
 
    # Use this for today's Bing Wallpaper 
    filename="$PICTURE_DIR/bing-wallpaper.$file_ext"

    # Use this for every days file with timestamp
    # filename="$PICTURE_DIR/bing-wallpaper-$today.$file_ext"
    
    # Download the file
    echo "Downloading: $filename ..."
    curl -sSLo $filename $urls  
         
    # # Use this for today's and next day's Bing Wallpaper -- Not working anymore
      
    # for p in ${urls[@]}; do
    #     filename=$(echo $p|sed -e "s/.*\/\(.*\)/\1/")
    #     if [ ! -f $PICTURE_DIR/$filename ]; then
    #         echo "Downloading: $filename ..."
    #         file_ext = $filename | sed -e "s/.*\.//g"
    #         curl -sSLo "$PICTURE_DIR/bing-wallpaper-$today.$file_ext" $p
    #     else
    #         echo "Skipping: $filename ..."
    #     fi
    # done
 
    killall Dock
    exit 0
fi
echo "We could not download the image, please report the issue here - https://github.com/sakiv/bing-wallpaper-mac/issues" 
exit 99