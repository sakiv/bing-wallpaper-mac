#!/usr/bin/env bash
 
PICTURE_DIR="$HOME/Pictures/Bing-Wallpapers"
 
mkdir -p $PICTURE_DIR
 
# Picks
# urls=( $(curl -s http://www.bing.com | \
#     grep -Eo "url:'.*?'" | \
#     sed -e "s/url:'\([^']*\)'.*/http:\/\/bing.com\1/" | \
#     sed -e "s/\\\//g") )
 
urls=( $(curl -s http://www.bing.com | \
    grep -Eo "g_img={url: \".*?\"" | \
    sed -e "s/g_img={url: \"//g" | \
    sed -e "s/\"//g" | \
    sed -e "s/\\\u0026/\&/g" ) )
 
if [ "$urls" = "" ]
then   
    urls=( $(curl -s http://www.bing.com | \
        grep -Eo "g_img={url: \".*?\"" | \
        sed -e "s/g_img={url: \"\([^\"]*\)\".*/http:\/\/bing.com\1/" | \
        sed -e "s/\\\//g" | \
        sed -e "s/\\\u0026/\&/g" ) )
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
#           curl -Lo "$PICTURE_DIR/$filename" $p
#       else
#           echo "Skipping: $filename ..."
#       fi
#   done
 
    killall Dock
    exit 0
fi
 
exit 99