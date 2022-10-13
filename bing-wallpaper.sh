#!/usr/bin/env bash
 
PICTURE_DIR="$HOME/Pictures/Bing-Wallpapers"
 
mkdir -p $PICTURE_DIR

# Picks
# urls=( $(curl -sSL http://www.bing.com | \
#     grep -Eo "url:'.*?'" | \
#     sed -e "s/url:'\([^']*\)'.*/http:\/\/bing.com\1/" | \
#     sed -e "s/\\\//g") )
 
urls=( $(curl -sSL https://www.bing.com | \
    grep -Eo "g_img={url:\s*\".*?\"" | \
	sed -e "s/g_img={url:\s*\"//g" | \
	sed -e "s/\"//g" | \
	sed -e "s/\\\u0026/\&/g" ) )

if [ "$urls" = "" ]
then   
	urls=( $(curl -sSL https://www.bing.com | \
    	grep -Eo "g_img={url:\s*\".*?\"" | \
		sed -e "s/g_img={url:\s*\"\([^\"]*\)\".*/http:\/\/bing.com\1/" | \
		sed -e "s/\\\//g" | \
		sed -e "s/\\\u0026/\&/g" ) )
fi

if [ "$urls" = "" ]
then	
	urls=( $(curl -sSL https://www.bing.com | \
    	grep -Eo "background-image: url\(.*\.jpg\)" | \
		sed -e "s/background-image: url(//g" | \
		sed -e "s/)//g" ) )
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
 
    rm -Rf $PICTURE_DIR/*.*
 
#   Use this for today's Bing Wallpaper 
    filename=$(echo $urls|sed -e "s/.*\/\(.*\)/\1/")
    # echo $urls
    # exit 0
    curl -Lo "$PICTURE_DIR/$filename" $urls  
         
#   Use this for today's and next day's Bing Wallpaper 
#       
#   for p in ${urls[@]}; do
#       filename=$(echo $p|sed -e "s/.*\/\(.*\)/\1/")
#       if [ ! -f $PICTURE_DIR/$filename ]; then
#           echo "Downloading: $filename ..."
#           curl -sSLo "$PICTURE_DIR/$filename" $p
#       else
#           echo "Skipping: $filename ..."
#       fi
#   done
 
    killall Dock
    exit 0
fi
echo "We could not download the image, please report the issue here - https://github.com/sakiv/bing-wallpaper-mac/issues" 
exit 99