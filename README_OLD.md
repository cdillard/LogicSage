## Description

### Powered by - [OpenAI GPT-4, GPT-3.5 turbo APIs], THANK YOU!

LogicSage is an open-source AI workspace for everyone. Chat w/ GPTs. Developers and AI enthusiasts can use it to work with gpts to view code, edit code, and submit PRs!

 [LogicSage: The Mobile AI Workspace](https://apps.apple.com/us/app/logicsage/id6448485441) on the app store.

- This app is perfect for anyone who wants to get started with AI and learning how to prompt. 
- This app is also fantastic for developers who want to learn programming languages better using GPT.
- This app allows you to check out and examine this apps, or any git repositories source code. The source code viewing file windows are fully color customizable.
- This app allows you to talk with GPTs via views in the app.
- This app allows you to talk with chat API via a command line interface including a toolbar and a command bar.
- All you need is a A.I. API Key to be entered in the Settings menu.

Gist of modes: 
iOS app allows working in phone mode for interaction without a mac. 
more with the SwiftSage CLI for Mac including a server...
- Swift Vapor Server records GPT interaction and allows remote control of computer for building A.I. generated Xcode projects.
- Keep in mind this is an alpha project/app. Please email me or get in touch via support issues to help me finish this app.
- Integration with text to speech software in both the client and server.
- In computer mode: Debate mode: pit the GPT personas against one another with "debate" and "debate your topic”
---

Supported modes can be toggled in the Settings(gear icon) menu.

mobile: this mode allows you to interact with GPT by prefixing your prompt in the command entry window with the g key.

---

computer:  this more advanced mode allows you to create apps automatically in Xcode with the (i) command.

—-

Future of LogicSage:
Google and Link cmd support coming soon!

—-

Demo video (please download to mac or iOS device to view): https://github.com/cdillard/SwiftSage/blob/main/LogicSageDemo.MOV
—-
----------------

## news
----------------
05-25-2023

## LogicSage 1.1.9 rolling out! 

https://apps.apple.com/us/app/logicsage/id6448485441?platform=iphone

Feat: 
-New Proper GPT Chat w/ history and multiple chats and windows! 
- iOS Simulator mirrors mac simulator in computer mode.Easy random wallpaper and simulator button.

----------------
05-22-2023

## LogicSage 1.1.8 rolling out! 

https://apps.apple.com/us/app/logicsage/id6448485441?platform=iphone

What's New:
Features: Feel the chat with Haptic Feedback! Realtime chat with GPTs.

Stay tuned folks! More coming soon. 

- Publishing generated iOS apps to Swift playground project for imeadiate opening on iPad :)
- Workspace syncing between mac and iOS. This will allow rapid iteration on AI generated projects. 
- Run Xcode project and see simulator screen capture in LogicSage!

LogicSage 1.1.7 LIVE in the App Store for FREEE now!

https://apps.apple.com/us/app/logicsage/id6448485441?platform=iphone

----------------
05-20-2023

## LogicSage 1.1.7 rolling out! 

LogicSage 1.1.7 build 2 coming to the App Store ASAP!

Build from source if you want to try Streaming CHAT!

LogicSage is the AI workspace for everyone. Create AI generated iOS apps! Streaming CHAT! No more waiting for responses! Deep color, settings, and background customizing.

LogicSage is the AI workspace for everyone. Chat w/ GPTs. Developers and AI enthusiasts can use it to work with gpts to view code, edit code, and submit PRs!

This app and its server are 100% open source, written in Swift, and available on github here: https://github.com/cdillard/LogicSage.

What's New:
Features: Streaming CHAT! No more waiting for responses. Change your LogicSage background! Transparent UIs!
Fixes: Squashed repo forking/downloading bugs!

----------------
05-19-2023

CUSTOMIZABLE WALLPAPERS MAC -> LogicSage!!!!

Run `./copy_wallpapers.sh` to copy your existing Mac OS Desktops to the SwiftyGPTWorkspace. This is where LogicSage will grab your desired wallpaper backgrounds from.

WANT EVEN MORE BACKGROUNDS: https://forums.macrumors.com/threads/project-complete-collection-of-mac-os-wallpapers-updated.2036834/ download and unzip this bad boy to the `~/SwiftyGPTWorkspace/Wallpaper` folder.

Search the internet for "4K Wallapaper zip + Space" replacing Space with whatever type of background you want. Download the heic, jpeg, jpg, and png images you'd like to use as wallpapers.

AI Generated PR titles and commit messages (coming soon)


## Getting Started
1. Clone the repository: `git clone https://github.com/cdillard/SwiftSage.git`
2. Navigate to the project directory: `cd SwiftSage`
3. Follow the [Installation](#installation) and [Configuration](#configuration) steps below.


## Configuration
1. Open `Swifty-GPT.xcworkspace`.
2. Change to your Development Code Signing info.
2. Set `OPEN_AI_KEY` in `GPT-Info.plist`.`

	- Optional for customizable bgs: Run `./copy_wallpapers.sh` to copy your existing Mac OS Desktops to the SwiftyGPTWorkspace. This is where LogicSage will grab your desired wallpaper backgrounds from.

3. Run `./run.sh` from within SwiftSage folder root to run the Swift Sage Server and Swifty-GPT server binary.
3. Enjoy!


## Installation
### Dependencies
- [Homebrew](https://brew.sh/)
- [Ruby](https://www.ruby-lang.org/en/)
- [Xcode](https://developer.apple.com/xcode/)
- [XcodeGen](https://github.com/yonaskolb/XcodeGen)
- [Xcodeproj](https://github.com/CocoaPods/Xcodeproj)

- [Swift Toolchain Xcode 14.3](https://www.swift.org/download/)

#### Installing Homebrew and Ruby
If you don't have Homebrew and Ruby installed, follow these steps:
1. Install Homebrew by running: `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
2. Install Ruby by running: `brew install ruby`

#### Installing XcodeGen and Xcodeproj
1. Install XcodeGen: `brew install xcodegen`
2. Install Xcodeproj: `gem install xcodeproj`

## SET API KEYS
SET API KEYS: You'll need to track down the following keys to fully experience SwiftSage.

NOTE: NYTIMES,PIXABAY, and GOOGLE are not required (yet) but be sure that the feat flags for those features are disabled in your Config for now if not using please.

```
	<key>GOOGLE_KEY</key>
	<string></string>
	<key>OPEN_AI_KEY</key>
	<string></string>
	<key>GOOGLE_SEARCH_ID</key>
	<string></string>
	<key>NYTIMES_KEY</key>
	<string></string>
	<key>NYTIMES_SECRET</key>
	<string></string>
	<key>PIXABAY_KEY</key>
	<string></string>
```

Check Config.swift for the config.

You can turn on asciiAnimations for fun or turn them off for fun. Your choice.

-More : Move InputText and IdeaText to your `~Documents/SwiftyGPTWorkspace/`, this will be your primary entry point for idea and gpt prompts. The xcode terminal does not support pasting multiple lines of code so this is the best way. Use gptFile, ideaFile to execute.

### Path Configuration
You may need to change the `xcodegenPath` variable depending on your configuration:
- Option 1: `let xcodegenPath = "/Users/$USERNAME/.rbenv/shims/xcodegen"`
- Option 2: `let xcodegenPath = "/opt/homebrew/bin/xcodegen"`

To discover your paths and issues, run:
- `which xcodeproj`
- `which xcodegen`
If you encounter Ruby errors, follow the steps here: [StackOverflow Solution](https://stackoverflow.com/a/31250347)

## COMMANDS
Check the following link for the Swifty-GPT server command list.
https://github.com/cdillard/SwiftSage/blob/main/Swifty-GPT/Command/CommandTable.swift


Check the following out for the much shorter list of iOS commands for mobile mode. (Working to add these all so server isn’t required) 
https://github.com/cdillard/SwiftSage/blob/main/SwiftSageiOS/SwiftSageiOS/Command/CommandTable.swift




## UNDERSTANDING THE SWIFT SAGE COMPONENTS!
![SwiftSage](Swifty-GPT/assets/swifty-diagram.png)

---
## SWIFT SAGE IOS INSTRUCTIONS: (Not needed unless you want to use SwiftSage on iOS/iPadOS devices)

DO NOT use wireless debuggin, it won't work due to websockety conflict

UPDATE the feat flag
`let swiftSageIOSEnabled = true`

If you have issues: `rm -rf WebSocketServer/.build`

TURN OFF YOUR FIREWALLS ON ALL USED DEVICES

1. Install Vapor: `brew install vapor`



USE THIS COMMAND TO RUN VAPOR SERVER

```
cd  SwiftSageServer
rm -rf .build
vapor build
vapor run
```

## MAC SAGE INSTRUCTIONS:

MAC SAGE or SwiftSageForiOSForMac

I've included a mac OS app you can use for prompting, since the Xcode terminal is a bit rough.


## Troubleshooting

### Xcode build
`tessdata_fast-main` should be deleted from the Xcode project. It will be added to the SwiftyGPTWorkspace folder in your Documents dir.

---

### Microphone Access

NOTE: To enable the mic head to Config.swift and turn on `let voiceInputEnabled = true`


If you experience issues with microphone access/MIC POPUP, follow these steps:
1. Head to the Swifty-GPT folder and run the following command with your Apple Development account to stop the Mic popup:
Head to the Swifty-GPT folder and run this on the entitlements fil with your Apple Development account. This will stop the Mic POPUP.
 `codesign --entitlements Swifty-GPT.entitlements --force --sign "Apple Development: yourdevemail@gmail.com (YOUTEAXZM)" ../Xcode/DerivedData/Swifty-GPT-fsilcclqupwxmwfxejzmbhescakg/Build/Products/Release/Swifty-GPT`

![Microphone Access](Swifty-GPT/assets/MicAccess.png)

If you see dialogs such as "would like to use your Microphone" or "Would like to send events to other applications," please accept them.

---
Sometimes GPT will refuse to make apps....
```
Response non nil, another generation...
🤖: Sorry, as an AI language model, I am not able to develop an iOS app. My capabilities are limited to generating human-like text based on the given prompts.
found [] names
found [] commands
📁 found = 0
No names found... failing..
(Function)
```
If this happens just try again and it _usually_ clears right up.

Thanks to Mike Bruin for keeping the Plist safe.

---
Unlocking the Power of the Future: Exploring the Intersection of Mobile and Artificial General Intelligence Programming. In this project, an expert in the field of mobile technology works on ways in which these two fields are converging and changing the way we interact with technology.
---

DISCLAIMER: I am not responsible for any issues (legal or otherwise) that may arise from using the code in this repository. This is an experimental project, and I cannot guarantee its contents.

## Why did I make this?

![LogicSage1](Swifty-GPT/assets/iOSsws1.PNG)
![LogicSage2](Swifty-GPT/assets/iOSsws2.PNG)
![LogicSage3](Swifty-GPT/assets/iOSsws3.PNG)

MISC 

### OCR Models (not needed currently)
Download the necessary OCR models and place them in the corresponding directories:
1. [tessdata_fast](https://github.com/tesseract-ocr/tessdata_fast): Place the contents in `../SwiftyGPTWorkspace/tessdata_fast-main`.
2. [tessdata](https://github.com/tesseract-ocr/tessdata)
3. [tessdata_best](https://github.com/tesseract-ocr/tessdata_best)

### Voice Command
Download the desired datasets from [Hugging Face](https://huggingface.co/ggerganov/whisper.cpp/tree/main) and place them in `Swifty-GPT/Swifty-GPT/Model`:
- ggml-large.bin
- ggml-medium.en.bin
- ggml-large-v1.bin
- ggml-base.en.bin
- ggml-small.en.bn

---
## MAKING BUILT IN MAC OS VOICES THE BEST THEY CAN BE  (Not needed unless you want decent sounding voices)

If you would not like to hear ANYTHING from this tool please set `let voiceOutputEnabled = false`

-MAKE SURE YOU HAVE ALL POSSIBLE MAC OS VOICES INSTALLED BY GOING TO Settings -> Voice -> Spoken Content and downloading them all.

WANT A BETTER AND MORE REALISTIC SOUNDING VOICE????
```
// What YOU don't like the goofy robotic voices built in to Mac OS????
// DISABLED BY DEFAULT: SEE README AND https://www.cereproc.com
```
Just install the voices you want to Mac OS TTS, once they are installed check out their identifier in Sw-S with (5) and add them to the config.swift.

FIND/BUY/INSTALL THE VOICE YOU FANCY.
https://www.cereproc.com

DISCLAIMER: I am not responsible for any issues (legal or otherwise) that may arise from using the code in the SwiftSage repository or using the LogicSage app. This is an experimental project, and I cannot guarantee its contents.
