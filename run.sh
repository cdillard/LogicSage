#!/bin/bash

# TODO: Change to use passed or ENV VAR
cd  ~/LogicSage/

lsof -i :8080 -sTCP:LISTEN | awk 'NR > 1 {print $2}' | xargs kill -15

killall SwiftSageStatusBar
killall Swifty-GPT

### USE THIS FOR Terminal.app
cwd=$(pwd)
bar="${cwd}/SwiftSageServer"
osascript -  "$bar"  <<EOF
    on run argv
        tell application "Terminal"

            do script( "cd " & quoted form of item 1 of argv & " ; swift run")

        end tell
    end run
EOF

# ## LAUNCH SWIFT SERVER COMMAND LINE BINARY

sleep 20

# rm -rf dd

cwd=$(pwd)

osascript -  "$cwd"  <<EOF
    on run argv
        tell application "Terminal"

            do script( "cd " & quoted form of item 1 of argv & " ; xcodebuild -derivedDataPath dd -workspace Swifty-GPT.xcworkspace -scheme Swifty-GPT -configuration Debug clean build ; dd/Build/Products/Debug/Swifty-GPT")

        end tell
    end run
EOF
