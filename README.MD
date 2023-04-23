![Swifty-GPT](Swifty-GPT/assets/Swifty-Logo.png)

# Swifty-GPT: The Ultimate AI Integration for Xcode

Swifty-GPT is a powerful tool for creating apps on Apple devices like iPhones, Macs, and more. It helps with everything in Xcode, from starting projects to fixing bugs, and even automating tasks with AI integration. Whether you're developing a fun game or a professional business app, Swifty-GPT makes the whole process smoother and easier in Xcode.

## Table of Contents
- News, Changelog
- [Getting Started](#getting-started)
- [Installation](#installation)
- [Configuration](#configuration)
- [Troubleshooting](#troubleshooting)
- [Features](#features)
- [Credits](#credits)
- [Contact](#contact)

DISCLAIMER: I AM NOT RESPONSIBLE FOR ANY ISSUES RESULTING FORM THE USE OF THE CODE IN THIS REPOSITORY. THIS IS JUST AN EXPERIMENT.

## News, Changelog
----
04-22-2023

SwiftSage has evolved. realtime voice synthesis and google command gives super powers to your SwiftSage `i` and `if` and `gf` commands.

AGI is imminent. (NOT THIS PROJECT LOL) We might get some funny apps tho...

## Getting Started
1. Clone the repository: `git clone https://github.com/username/Swifty-GPT.git`
2. Navigate to the project directory: `cd Swifty-GPT`
3. Follow the [Installation](#installation) and [Configuration](#configuration) steps below.

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

### OCR Models
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

## Configuration
1. Open `Swifty-GPT.xcworkspace`.
2. Set `OPEN_AI_KEY`.
3. Enjoy!

-More : Move InputText and IdeaText to your `~Documents/SwiftyGPTWorkspace/`, this will be your primary entry point for idea and gpt prompts. The xcode terminal does not support pasting multiple lines of code so this is the best way. Use gptFile, ideaFile to execute.

### Path Configuration
You may need to change the `xcodegenPath` variable depending on your configuration:
- Option 1: `let xcodegenPath = "/Users/$USERNAME/.rbenv/shims/xcodegen"`
- Option 2: `let xcodegenPath = "/opt/homebrew/bin/xcodegen"`

To discover your paths and issues, run:
- `which xcodeproj`
- `which xcodegen`

If you encounter Ruby errors, follow the steps here:

If you encounter Ruby errors, follow the steps here: [StackOverflow Solution](https://stackoverflow.com/a/31250347)


## Troubleshooting

### Xcode build
`tessdata_fast-main` should be deleted from the Xcode project. It will be added to the SwiftyGPTWorkspace folder in your Documents dir.

### Microphone Access

NOTE: To enable the mic head to Config.swift and turn on `let voiceInputEnabled = true`


If you experience issues with microphone access/MIC POPUP, follow these steps:
1. Head to the Swifty-GPT folder and run the following command with your Apple Development account to stop the Mic popup:
Head to the Swifty-GPT folder and run this on the entitlements fil with your Apple Development account. This will stop the Mic POPUP.
 `codesign --entitlements Swifty-GPT.entitlements --force --sign "Apple Development: yourdevemail@gmail.com (YOUTEAXZM)" ../Xcode/DerivedData/Swifty-GPT-fsilcclqupwxmwfxejzmbhescakg/Build/Products/Release/Swifty-GPT`

![Microphone Access](Swifty-GPT/assets/MicAccess.png)

If you see dialogs such as "would like to use your Microphone" or "Would like to send events to other applications," please accept them.


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

### Stopping Robot Voices
If you ever have robot voices getting away from you, run `killall say` in the terminal to stop them.

## Features
Swifty-GPT offers a range of features to make software development faster and more efficient:
- Code analysis and optimization
- Error detection and correction
- Voice-activated GPT integration
- Real-time code suggestions
- Powerful debugging tool
- Integration with Apple's built-in text-to-speech software
- Personalized memory storage using a consciousness module

## Credits
- [SwiftWhisper](https://github.com/exPHAT/SwiftWhisper)
- [SwiftyTessarect](https://github.com/SwiftyTesseract/SwiftyTesseract)
- [OpenAI GPT-4, GPT-3.5 turbo APIs](https://www.openai.com)
- [AudioKit](https://github.com/AudioKit/AudioKit)

- [SwiftSoup]
- [SwiftNLC]
- [SourceKitten]

## Contact
Created by: Chris Dillard (c_h_r_i_s_b_d_i_l_l_a_r_d_@_g_m_a_i_l.com)

- With a little help from my GPT🤖. Thank you, OpenAI!

Feel free to reach out on [Discord](https://discord.gg/6hbDDqf8SX) if you have any questions or need support.

**Note:** iPad and iOS support is coming soon!