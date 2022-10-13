# Bing Desktop Wallpaper for Macs
This application can be used to change and refresh your Mac desktop wallpaper every day from Bing.

*Note: This application is tested with only Macs. For any other operating system you can try but it is not recommended.*
## Installation
---
You can deploy this application either using installation script (recommended) or manually.
* ### Installation Script

    You can install the script using the following command. Copy this command and paste it on your Mac terminal.

    ```bash
    $ sh -c "$(curl -fsSL https://raw.githubusercontent.com/sakiv/bing-wallpaper-mac/dev/install.sh?`date '+%s'`)"
    ```

* ### Manual Steps
    *Note: You have to follow these steps in sequence. If you miss any one of these steps then application may not work as expected.* 

    * Download latest compressed file, i.e. `bing-wallpaper-mac.tar.gz`, from the [releases](https://github.com/sakiv/bing-wallpaper-mac/releases) page.
    * Extract file either by double clicking on it or using following command on terminal (assuming you have downloaded the file in your home directory - $HOME or ~)
        ```bash
        $ tar -xvf ~/bing-wallpaper-mac.tar.gz -C ~/bing-wallpaper-mac
        # Sample output
        # x ./
        # x ./LICENSE
        # x ./README.md
        # x ./com.yourname.bing-wallpaper.plist
        # x ./bing-wallpaper.sh
        ```
    * After extracting files, you should see the following files
        ```
        |-- bing-wallpaper.sh    
        |-- com.yourname.bing-wallpaper.plist    
        │-- LICENSE
        │-- README.md
        ```
    * Rename `com.yourname.bing-wallpaper.plist` file to appropriate name, for example - `com.johndoe.bing-wallpaper.plist`
        ```bash
        $ mv ~/bing-wallpaper-mac/com.yourname.bing-wallpaper.plist ~/bing-wallpaper-mac/com.johndoe.bing-wallpaper.plist
        # Empty output
        ```
    * Now open `com.johndoe.bing-wallpaper.plist` file in an editor of your choice, and replace the following lines with appropriate values
        ```xml
        <!-- Replace {YOUR-NAME} with appropriate name used in previous step, for example - johndoe -->
        <string>com.{YOUR-NAME}.bing-wallpaper</string>
        ...
        ...
        <!-- Replace {TARGET-FOLDER} where you have extracted the tar file, for example - ~/bing-wallpaper-mac -->
            <string>{TARGET-FOLDER}/bing-wallpaper.sh</string>
        </array>
        ```
    * Move newly renamed file `com.johndoe.bing-wallpaper.plist` to `~/Library/LaunchAgents` folder
        ```bash
        $ mv ~/bing-wallpaper-mac/com.johndoe.bing-wallpaper.plist ~/Library/LaunchAgents/
        # Empty output
        ```
    * Run the following command on terminal to register the script with Mac OS
        ```bash
        $ launchctl load ~/Library/LaunchAgents/com.johndoe.bing-wallpaper.plist
        # Empty output
        ```
    * To verify that script is successfully registered with Mac OS, run the following command on the terminal
        ```bash
        $ launchctl list | grep com.johndoe.bing-wallpaper
        
        # Successful output
        -	0	com.johndoe.bing-wallpaper

        # If it did not register successfully then you will see empty output
## License
---
This application is licensed under the MIT license.

## Contributors
---
If you would like to contribute to this project, please contact the author of this project.