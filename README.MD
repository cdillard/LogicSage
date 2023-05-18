
# LogicSage: The mobile AI workspace 

## for Mac OS command line, iOS, and iPadOS - Open Source in Swift

[LogicSage: The Mobile AI Workspace](https://apps.apple.com/us/app/logicsage/id6448485441) - on the AppStore for free now!

## Table of Contents
- [Contact](#contact)
- [News](#news)
- [Getting Started](#getting-started)
- [Installation](#installation)
- [Configuration](#configuration)
- [Troubleshooting](#troubleshooting)
- [Credits](#credits)

---
## Contact
Created by: Chris Dillard (c_h_r_i_s_b_d_i_l_l_a_r_d_@_g_m_a_i_l.com) w/ underscores removed.

- With a little help from my GPT🤖. Thank you, OpenAI!
---

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

## news

---

05-17-2023

## LogicSage 1.1.6 rolling out! 

[LogicSage: The Mobile AI Workspace](https://apps.apple.com/us/app/logicsage/id6448485441) - on the AppStore for free now!


Introducing the revolutionary….. Fork button! 
bugs with multiple repos fixed. 

more fixes for git features and git commit graph display comjng soon folks!


---

05-16-2023

## LogicSage 1.1.5 rolling out! 

fixes thet nasty crash trying to share output from GPT terminal on iPad

MORE feat/fixes in the works folks! I made this PR in LogicSage ;).  . 

[LogicSage: The Mobile AI Workspace](https://apps.apple.com/us/app/logicsage/id6448485441) - on the AppStore for free now!

---

05-15-2023

Rolling out LogicSage 1.1.4, with features galore!

In this alpha you push PRs, the Working Stages view raises the bars,

Bugs squashed, UI refined, for a better user time.

Enjoy the new Settings and Add/Open view!

[Demo Video](https://github.com/cdillard/SwiftSage/blob/main/LogicSageDemo.MOV)

--------

05-11-2023

There will be fixes. 1.1.3 is out there now. Many things are fixed. Many issues remain. 

Finding the balance between fixes and features and real jobs.

Update 5/15
Theme buttons added to settings!

---
05-09-2023
There will be bugs

I'm working to resolve the issues with battery drain and multi-window behavior. I'm working to fix the apps performance when there is many windows or repositories of large size open.

ROADMAP:

I'm adding "write" git features to this app. You will be able to push and pull, git fetch and view commits, make a branch or a PR. A.I. Will be integrated in such a way that your commit messages and PR titles and descriptions and code such as documenation will be augmented with A.I. generated text.

Movies mode, Debate mode enhancements, and more! 

---

05-09-2023

[LogicSage: The Mobile AI Workspace](https://apps.apple.com/us/app/logicsage/id6448485441) - on the AppStore for free now!

Feedback in Github Issues please! Thank you if you try!

---
05-08-2023

Multiple repositories can be downloaded to your device! Woo! Enjoy all those tasty codes even on the go in the tunnel. Stay tuned for the next updates folks.
---

05-07-2023
Introducing customizable Source Editor colors! Check it out in Settings :)

Introducing multiple window support. Introducing smooth resizability. Introducing Window List in Add View.

Introducing your repository in LogicSage: Simply set your github PAT, github owner, github repo, and github branch and then tap Download Repo in the Add View This will grab the repo from Github. Cool!

Ability to Create PRs, Create Branches, View working Changes, View Commits coming Soon!
---

## Getting Started
1. Clone the repository: `git clone https://github.com/cdillard/SwiftSage.git`
2. Navigate to the project directory: `cd SwiftSage`
3. Follow the [Installation](#installation) and [Configuration](#configuration) steps below.


## Configuration
1. Open `Swifty-GPT.xcworkspace`.
2. Change to your Development Code Signing info.
2. Set `OPEN_AI_KEY` in `GPT-Info.plist`.`
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
cd  WebSocketServer
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


---
## Credits
- [SwiftWhisper](https://github.com/exPHAT/SwiftWhisper)
- [SwiftyTesseract](https://github.com/SwiftyTesseract/SwiftyTesseract)
- [OpenAI GPT-4, GPT-3.5 turbo APIs](https://www.openai.com)
- [AudioKit](https://github.com/AudioKit/AudioKit)
- [SwiftSoup](https://github.com/scinfu/SwiftSoup)
- [SwiftNLC](https://github.com/JacopoMangiavacchi/SwiftNLC)
- [SourceKitten](https://github.com/jpsim/SourceKitten)
- [MultiPeerKit](https://github.com/insidegui/MultiPeerKit)
- [LocalConsole](https://github.com/duraidabdul/LocalConsole)
- [Starscream](https://github.com/daltoniam/Starscream)
- [Vapor](https://github.com/vapor/vapor)
- [LocalConsole](https://github.com/duraidabdul/LocalConsole)
- [Blackhole](https://github.com/ExistentialAudio/BlackHole)
- [SourceEditor](https://github.com/louisdh/source-editor)
- [savannakit](https://github.com/louisdh/savannakit)
- [Sourceful](https://github.com/twostraws/Sourceful)
- [zip-foundation](https://github.com/weichsel/ZIPFoundation)
---
Thanks to Mike Bruin for keeping the Plist safe.

---
Unlocking the Power of the Future: Exploring the Intersection of Mobile and Artificial General Intelligence Programming. In this project, an expert in the field of mobile technology works on ways in which these two fields are converging and changing the way we interact with technology. From the impact of machine learning on mobile apps to the future of robotics and automation, this project explores the cutting edge of innovation and speculates on what the future may hold. Join me as we delve into the possibilities of a world transformed by the power of technology.


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

new archvie 

05-05-2023

What is it? A workspace, a git client, an AI project generator? A song maker? A debate practice tool? 
Help me decide!

Welcome to LogicSage. 

Now with GIT REPO SUPPORT!

Your precious API Keys are now stored in the Keychain :)

You can now enter a Github PAT in settings, then go to the Addiew and tap "Download sws repo" , hide the add view, once the download completes open the add view and browse away! Select files and drill down to check out the LogicSage mobile AI workspace code.

---
05-04-2023

Another day full of excitement for LogicSage!

-You can now choose whatever gpt model you would like to use with the chat/completions API.
-It's starting out with gpt-3.5-turbo, but you can use gpt-4 too.

-Keep in mind you must manually set your GPT model in the Config of Swifty-GPT command line app. So go ahead and do that if you plan on using GPT-4. I've left it as gpt-3.5-turbo.

---- 
05-02-2023

You can now use the Swift Sage app without the server, Have fun! 

Coming to an app store near you for free soon.

![modez](Swifty-GPT/assets/modez.png)


---- 
05-01-2023

Resizable Webview windows and Resizable File windows. Bug fixes galore.

Rewrote Vapor server to support multiple users authenticating :).

Redid SwiftSage iOS UI for more screen real estate.

Google Command Progress, try it with `g` command, turn off enableGoogle in server if causing issues.

---- 
04-30-2023

Swift Sage is getting mroe mobile!

Voice synthesis with configurable voice, in the iOS app. Voice recognition using the mic button in the iOS app. Have fun!

Check it out. Email me with questions or suggestions.

---- 
04-28-2023

DEBATE MODE UPGRADE:

`debates`
`debates subject`

CEREPROC instructions updated, you should be able to use the ones that install into Mac OS voices by default now.
Customize to use cereproc voices in Debates.swift . See COnfig.swift for detailed voice setup instructions :thumbup:

---- 
04-26-2023

Files using twostraws excellent Sourceful (see creds)

Webviews for GPT-4!

See Screenshots at bottom

Stay TUNED for multiple TERM windows AND MORE!

----
04-26-2023

iOS input works quite well, give your feedback in Discussions

"debate your topic" mode BETA

Customizable Terminal and app colors (Restart or fresh install app to apply/reset colors for now please.)

CommandButton and wonderful SwiftUI code thanks to GPT-4 and I's coding chemistry.

----
04-24-2023

iOS Swift Sage??? Whattttt??? Yep.
More screenshots at the bottom

----
04-23-2023: DEBATE MODE introduced.

----
04-22-2023

SwiftSage evolves with real-time voice synthesis and Google command integration for enhanced SwiftSage features.



# This Github project is hooked up to Xcode cloud. new branches will be tested on Apples testing infrastructure.
