
-- Print all window titles


-- Print all window titles


display dialog "This script requires elevated privileges. Please enter your administrator password." with title "Elevated Privileges" with icon note buttons {"Cancel", "OK"} default button "OK" default answer "" with hidden answer
set admin_password to text returned of the result

set app_names to {}
set all_apps to {}
try
    do shell script "echo '" & admin_password & "' | sudo -S /usr/bin/true"
    tell application "System Events"
        set UI elements enabled to true
        set all_apps to every process whose visible is true
    end tell
    repeat with this_app in all_apps
        set app_name to name of this_app
        tell application "System Events"
            tell this_app
                set window_list to every window
            end tell
        end tell
        repeat with this_window in window_list
            set window_title to my getWindowTitle(this_window)
            if window_title is not missing value then
                log "App: " & app_name & ", Window title: " & window_title
            end if
        end repeat
    end repeat
end try

tell application "System Events" -- Add this block
    log "WTF: "

    set app_names to {}
    repeat with this_app in all_apps
        log "WTF2: "

        set end of app_names to name of this_app
    end repeat

    log "All apps: " & app_names

    repeat with this_app in all_apps
        set app_name to name of this_app
        tell application "System Events"
            tell this_app
                set window_list to every window
            end tell
        end tell

        repeat with this_window in window_list
            set window_title to my getWindowTitle(this_window)
            if window_title is not missing value then
                log "App: " & app_name & ", Window title: " & window_title
            end if
        end repeat
    end repeat
end tell

on getWindowTitle(window_ref)
    try
        tell application "System Events"
            set window_title to title of window_ref
        end tell
        return window_title
    on error
        return missing value
    end try
end getWindowTitle


on capture_window_by_title(target_window_title)
    set desktop_path to (path to desktop as text)
    set screenshot_path to desktop_path & "screenshot.png"
    set posix_screenshot_path to POSIX path of screenshot_path

    tell application "System Events"
        set process_list to every process whose name is not "Finder"
    end tell

    log "Target window title: " & target_window_title

    repeat with current_process in process_list
        set app_name to name of current_process
        log "Current app: " & app_name

        tell application "System Events"
            tell current_process
                set window_list to every window
            end tell
        end tell

        log "Target window title: " & target_window_title

        repeat with current_window in window_list
            set window_title to my getWindowTitle(current_window)
            if window_title is not missing value then
                log "App: " & app_name & ", Window title: " & window_title -- Log the window title

                if window_title as text is target_window_title as text then
                    try
                        tell application app_name
                            set winID to id of current_window
                            do shell script "screencapture -l " & winID & " " & quoted form of posix_screenshot_path
                        end tell
                        return posix_screenshot_path
                    on error error_message
                        return "Error capturing window: " & error_message
                    end try
                end if
            end if
        end repeat
    end repeat

    return "Window not found."
end capture_window_by_title


--set target_window_title to "Swifty-GPT — AEyes.swift"
--capture_window_by_title(target_window_title)





