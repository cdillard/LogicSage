#!/bin/bash

# Start Vapor server
rm -rf ./WebSocketServer/.build

cwd=$(pwd)
bar="${cwd}/WebSocketServer"
osascript -  "$bar"  <<EOF
    on run argv
        tell application "Terminal"

            do script( "cd " & quoted form of item 1 of argv & " ; vapor run")

        end tell
    end run
EOF

# # Store the PID of the Vapor server
# server_pid=$!

rm -rf dd

## LAUNCH SWIFT SERVER COMMAND LINE BINARY

xcodebuild -derivedDataPath dd -workspace Swifty-GPT.xcworkspace -scheme Swifty-GPT -configuration Debug clean build

./dd/Build/Products/Debug/Swifty-GPT

# # Store the PID of the command line target
# target_pid=$!

# # Wait for either process to exit
# wait -n

# # If we get here, one of the processes has exited
# # Kill the other one
# kill -TERM $server_pid $target_pid

# # Exit with an error code to signal that we should be restarted
# exit 1

# creates a new terminal window
