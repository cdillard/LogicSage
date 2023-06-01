#!/bin/bash

# Start Vapor server
rm -rf ./WebSocketServer/.build

lsof -i :8080 -sTCP:LISTEN | awk 'NR > 1 {print $2}' | xargs kill -15
killall SwiftSageStatusBar

### USE THIS FOR Terminal.app
cwd=$(pwd)
bar="${cwd}/WebSocketServer"
osascript -  "$bar"  <<EOF
    on run argv
        tell application "Terminal"

            do script( "cd " & quoted form of item 1 of argv & " ; vapor run")

        end tell
    end run
EOF

### USE THIS FOR iTerm2.app
# cwd=$(pwd)
# bar="${cwd}/WebSocketServer"
# osascript -  "$bar"  <<EOF
#     on run argv
#         tell application "iTerm2"
#             set newWindow to (create window with default profile)
#             tell current session of newWindow
#                 write text "cd " & quoted form of item 1 of argv & " ; vapor run"
#             end tell
#         end tell
#     end run
# EOF

# Vapor starts too fast :*()
sleep 20

rm -rf dd

## LAUNCH SWIFT SERVER COMMAND LINE BINARY

killall Swifty-GPT

xcodebuild -derivedDataPath dd -workspace Swifty-GPT.xcworkspace -scheme Swifty-GPT -configuration Debug clean build

./dd/Build/Products/Debug/Swifty-GPT
