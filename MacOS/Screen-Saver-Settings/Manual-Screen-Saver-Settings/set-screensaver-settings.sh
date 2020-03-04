#!/bin/sh

#
#   GitHub: captam3rica
#

###############################################################################
#
#   DESCRIPTION
#
#       A script to set the screensaver settings that are not configurable
#       via com.apple.screensaver.plist.
#
#       In my testing, the idleTime, tokenRemovalAction, and CleanExit settings
#       are the on options that are manageable through the main
#       com.apple.screensaver plist. As such, they are not modifiable when
#       deployed via mobileconfig.
#
#       The ByHost directory under the user's ~/Library/Preferences/ByHost path
#       manages the other settings.
#
#       Three other plist files aid in managing the Screensaver settings.
#
#           - com.apple.screensaver.machine_UUID.plist
#           - com.apple.ScreenSaverPhotoChooser.machine_UUID.plist
#           - com.apple.ScreenSaver.iLifeSlideShows.machine_UUID.plist
#
#       Other screensaver styles can have their own plist in the ByHost
#       directory. The iLifeSlideShows manages the Classic style.
#
#       This script was created based upon a number of sources found online as
#        such you mileage may very. Make sure to test in your environment.
#
###############################################################################


# Binaries used throughout this script
DEFAULTS="/usr/bin/defaults"
SUDO="/usr/bin/sudo"
KILLALL="/usr/bin/killall"
LOGGER="/usr/bin/logger"

# Define the preference domains
SCREENSAVER_BYHOST="com.apple.screensaver"
SCREENSAVER_PHOTO_CHOOSER="com.apple.ScreenSaverPhotoChooser"
ILIFE_SLIDE_SHOWS="com.apple.ScreenSaver.iLifeSlideShows"

# Path definitions
ILIFE_PATH="/System/Library/Frameworks/ScreenSaver.framework/PlugIns/iLifeSlideshows.appex"
CUSTOM_FOLDER_NAME="Screen_Saver_Photos"
CUSTOM_FOLDER="/Library/Screen Savers/$CUSTOM_FOLDER_NAME"
SELECTED_FOLDER="/Library/Screen Savers/$CUSTOM_FOLDER_NAME"



current_local_user(){
    # Return the current user on the Mac
    CURRENT_USER=$(printf '%s' "show State:/Users/ConsoleUser" | \
        /usr/sbin/scutil | \
        /usr/bin/awk '/Name :/ && ! /loginwindow/ {print $3}')
}


defaults_ch_write (){
    # Wrapper for the defaults currentHost write command.
    PLIST="$1"
    KEY="$2"
    printf "Writing to '%s' for currentHost\n" "$PLIST"
    "$SUDO" -u "$CURRENT_USER" "$DEFAULTS" -currentHost write "$PLIST" "$KEY"
}


defaults_read (){
    # Wrapper for the defaults read command
    # Reads in a preference domain and writes the output to stdout as the
    # current user on the current host machine.
    # Takes in a PLIST file name as $1 and a preference KEY as $2
    PLIST="$1"
    printf "Writing to: '%s' in the ByHost directory.\n" "$PLIST"
    "$SUDO" -u "$CURRENT_USER" "$DEFAULTS" -currentHost read "$PLIST"
}


write_screensaver_settings (){
    # Write screensaver settings for current host

    # CleanExit key
    "$SUDO" -u "$CURRENT_USER" "$DEFAULTS" -currentHost \
        write "$SCREENSAVER_BYHOST" \
        CleanExit -string "YES"

    # PrefsVersion key
    "$SUDO" -u "$CURRENT_USER" "$DEFAULTS" -currentHost \
        write "$SCREENSAVER_BYHOST" \
        PrefsVersion -int 100

    # moduleDict dictionary
    "$SUDO" -u "$CURRENT_USER" "$DEFAULTS" -currentHost \
        write "$SCREENSAVER_BYHOST" \
        moduleDict -dict \
        moduleName -string "iLifeSlideShows" \
        path -string "$ILIFE_PATH" type -int 0

    # showClock key
    "$SUDO" -u "$CURRENT_USER" "$DEFAULTS" -currentHost \
        write "$SCREENSAVER_BYHOST" \
        showClock -bool false
}


write_screen_saver_photo_chooser_settings (){
    # Write ScreenSaverPhotoChooser settings for current host.

    # CustomFolderDict dictionary
    "$SUDO" -u "$CURRENT_USER" "$DEFAULTS" -currentHost \
        write "$SCREENSAVER_PHOTO_CHOOSER" \
        CustomFolderDict -dict \
        identifier -string "$CUSTOM_FOLDER" \
        name -string "$CUSTOM_FOLDER_NAME"

    # LastViewedPhotoPath
    "$SUDO" -u "$CURRENT_USER" "$DEFAULTS" -currentHost \
        write "$SCREENSAVER_PHOTO_CHOOSER" \
        LastViewedPhotoPath -string ""

    # SelectedFolderPath key
    "$SUDO" -u "$CURRENT_USER" "$DEFAULTS" -currentHost \
        write "$SCREENSAVER_PHOTO_CHOOSER" \
        SelectedFolderPath -string "$SELECTED_FOLDER"

    # SelectedSource key
    "$SUDO" -u "$CURRENT_USER" "$DEFAULTS" -currentHost \
        write "$SCREENSAVER_PHOTO_CHOOSER" \
        SelectedSource -int 4

    # ShufflePhotos key
    "$SUDO" -u "$CURRENT_USER" "$DEFAULTS" -currentHost \
        write "$SCREENSAVER_PHOTO_CHOOSER" \
        ShufflesPhotos -bool false
}


write_ilife_slide_shows_settings (){
    # Write iLifeSlideshows settings for current host.

    # styleKey
    "$SUDO" -u "$CURRENT_USER" "$DEFAULTS" -currentHost \
        write "$ILIFE_SLIDE_SHOWS" \
        styleKey -string "Classic"
}


kill_all () {
    # Wrapper for hte killall binary.
    # Pass the name of the service that you want to kill as a string
    SERVICE="$1"
    "$KILLALL" "$SERVICE"
}


main () {
    current_local_user
    write_screensaver_settings
    write_screen_saver_photo_chooser_settings
    write_ilife_slide_shows_settings

    defaults_read "$SCREENSAVER_BYHOST"
    defaults_read "$SCREENSAVER_PHOTO_CHOOSER"
    defaults_read "$ILIFE_SLIDE_SHOWS"

    kill_all "cfprefsd"
}

main
