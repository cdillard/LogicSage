
# LogicSage: The GPT app for Apple platforms. (iPadOS, MacOS, and iOS) 

[LogicSage: AI iOS Code & Chat. (iPadOS, MacOS, iOS and more platforms soon!)](https://apps.apple.com/us/app/logicsage/id6448485441) - on the AppStore for free now!

# LogicSage 1.2.5 (latest release)
### What's New:
- Google Search Integration into GPT chat (use new added model `gpt-4-0314-web-browsing*`)
- Bug fixes and app enhancments to improve LogicSage chatting and coding!

## Table of Contents
- [Getting Started](#getting-started)
- [Installation](#installation)
- [Configuration](#configuration)
- [Contact](#contact)
- [Credits](#credits)

## Getting Started with LogicSage: iOS, iPadOS, MacOS

#### Chat and copy code snippets:

0. Download LogicSage from the AppStore.[link](https://apps.apple.com/us/app/logicsage/id6448485441)
1. LogicSage is a 'Bring Your Own API Key' app. Before you can start chatting, you need to enter an OpenAI API Key (https://platform.openai.com/account/api-keys) in the apps UI. 
    - it will be stored securely in your devices keychain. It will only be used when sending request to Open AI server (Check the source code in SettingsViewModel to check openAIKey handling.).

## Optional steps for additional features:

### Google Search API Integration: 

- Create a Google Custom Search API Key here. 

https://developers.google.com/custom-search/v1/introduction

- Get a Google Search API Key and Secret from Google Developer Console.
- Enter Google Search API Key and GooglE Search API Secret in Settings tab of app.
- Change model to `gpt-4-0314-web-browsing*` (this is added by LogicSage.)

### If you'd like to use LogicSageCommandLine in addition to the iOS client:
- Using LogicSage for Mac to launch the LogicSageCommandLine which allows 
-	to open / build AI geneaterated Xcode projects on your Mac.
-   open/run/edit Xcode projects on iOS. (Work in Progress)

0. Go to the root of your MacOS user directory (~)
	- `cd ~`

1. Clone the repository: `git clone https://github.com/cdillard/LogicSage.git`
	- You should now have the repository checked out in `~/LogicSage/`
2. Open `~/LogicSage/` in Finder.
3. Open `LogicSageCommandLine.xcworkspace` by double clicking it.
4. Set `OPEN_AI_KEY` in `GPT-Info.plist`.`

	- Optional for customizable bgs: Run `./copy_wallpapers.sh` to copy your existing Mac OS Desktops to the LogicSageWorkspace. This is where LogicSage will grab your desired wallpaper backgrounds from.

5. Download and run LogicSage.app from Releases.
![LogicSageMacUI](LogicSageMac.png)

6. Select `Start server` 

7. Observe launched Terminal windows running LogicSageCommandLine.

8. Create folder `~/Documents/LogicSageWorkspace`
9. Create folder `~/Documents/LogicSageForMacWorkspace`

## LogicSageCommandLine Installation Requirements
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

#### CUSTOMIZABLE WALLPAPERS MAC -> LogicSage!!!!

Run `./copy_wallpapers.sh` to copy your existing Mac OS Desktops to the LogicSageWorkspace. This is where LogicSage will grab your desired wallpaper backgrounds from.

WANT EVEN MORE BACKGROUNDS: https://forums.macrumors.com/threads/project-complete-collection-of-mac-os-wallpapers-updated.2036834/ download and unzip to the `~/LogicSageWorkspace/Wallpaper` folder.

Search the internet for "4K Wallapaper zip + Space" replacing Space with whatever type of background you want. Download the heic, jpeg, jpg, and png images you'd like to use as wallpapers.


---
## Disclaimer

I am not responsible for any issues (legal or otherwise) that may arise from using the code in this repository. This is an experimental project, and I cannot guarantee its contents.
The developer of this project does not accept any responsibility or liability for any losses, damages, or other consequences that may occur as a result of using this software. You are solely responsible for any decisions and actions taken based on the information provided by LogicSage.

## Token Usage Warning

Please note that the use of the GPT language model can be expensive due to its token usage. By utilizing this project, you acknowledge that you are responsible for monitoring and managing your own token usage and the associated costs. It is highly recommended to check your OpenAI API usage regularly and set up any necessary limits or alerts to prevent unexpected charges.

---
## Contact
Created by: Chris Dillard
- With a little help from my GPT🤖. Thank you, OpenAI!
---
## Credits

- [SwiftWhisper](https://github.com/exPHAT/SwiftWhisper)
- [SwiftyTesseract](https://github.com/SwiftyTesseract/SwiftyTesseract)
- [OpenAI GPT-4, GPT-3.5 turbo APIs](https://www.openai.com)
- [AudioKit](https://github.com/AudioKit/AudioKit)
- [SwiftSoup](https://github.com/scinfu/SwiftSoup)
- [SourceKitten](https://github.com/jpsim/SourceKitten)
- [Starscream](https://github.com/daltoniam/Starscream)
- [Vapor](https://github.com/vapor/vapor)
- [SourceEditor](https://github.com/louisdh/source-editor)
- [savannakit](https://github.com/louisdh/savannakit)
- [Sourceful](https://github.com/twostraws/Sourceful)
- [zip-foundation](https://github.com/weichsel/ZIPFoundation)
- [MacPaw's excellent OpenAI](https://github.com/MacPaw/OpenAI)
- [swift-png](https://github.com/kelvin13/swift-png)
- [nonstrict-hq ScreenCaptureKit-Recording-example](https://github.com/nonstrict-hq/ScreenCaptureKit-Recording-example/)
- [KeyboardAvoidanceSwiftUI](https://github.com/V8tr/KeyboardAvoidanceSwiftUI)
- [awesome-chatgpt-prompts](https://github.com/f/awesome-chatgpt-prompts)
- [Tikitoken](https://github.com/aespinilla/Tiktoken)
- [XcodeProj](https://github.com/tuist/XcodeProj)
- []
---
Unlocking the Power of the Future: Exploring the Intersection of Mobile and Artificial General Intelligence Programming. In this project, an expert in the field of mobile technology works on ways in which these two fields are converging and changing the way we interact with technology.