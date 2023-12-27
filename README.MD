
# LogicSage: AI Code & Chat on Apple platforms. (iPadOS, MacOS, and iOS) 

[LogicSage: AI iOS Code & Chat. (iPadOS, MacOS, iOS and more platforms soon!)](https://apps.apple.com/us/app/logicsage/id6448485441) - on the AppStore for free now!

## LogicSage 1.2.5 (latest)

- Work with Assistants and a thread is persisted to disk.

- Set Conversation temperature to control creativity of AI.

- Set your google search api key and secret (see README) and use -web-browsing suffixed model to use experimental Search and Link Command.


---

### Use LogicSage without Mac

Chat with GPT using tools (google, link) which allow incorporation of Google Search results into GPT responses.

## Getting Started with LogicSage: iOS, iPadOS

#### Chat and copy code snippets:

0. Download LogicSage from the AppStore.[link](https://apps.apple.com/us/app/logicsage/id6448485441)
1. LogicSage is a 'Bring Your Own API Key' app. Before you can start chatting, you need to enter an OpenAI API Key (https://platform.openai.com/account/api-keys) in the apps UI. 
    - it will be stored securely in your devices keychain. It will only be used when sending request to Open AI server (Check the source code in SettingsViewModel to check openAIKey handling.).

## Optional steps for additional features:

### Google Search API Integration: 

- Create a Google Custom Search API Key here. 

https://developers.google.com/custom-search/v1/introduction

- Get a Google Search API Key and Secret from Google Developer Console.
- Enter Google Search API Key and Google Search API Secret in Settings tab of app.
- Change model to `gpt-4-1106-web-browsing*` (this is added by LogicSage.)

### Use LogicSage with Mac by connecting to the LogicSageCommandLine app!

(Work in Progress) MacOS / iOS GPT Middleware that allows GPT to build, run, and test Xcode projects. 

When connected to the LogicSageCommandLine you can use the "Term" window from the LogicSage app, This allows you to invoke the commands on your mac from your device.

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

5. Open `LogicSage/LogicSage.xcodeproj` and run the Mac OS app.

6. Select `Start server` 

7. Observe launched Terminal windows running LogicSageCommandLine.

8. Create folder `~/Documents/LogicSageWorkspace`
9. Create folder `~/Documents/LogicSageForMacWorkspace`

---
## Disclaimer

I am not responsible for any issues (legal or otherwise) that may arise from using the code in this repository. This is an experimental project, and I cannot guarantee its contents.
The developer of this project does not accept any responsibility or liability for any losses, damages, or other consequences that may occur as a result of using this software. You are solely responsible for any decisions and actions taken based on the information provided by LogicSage.

## Token Usage Warning

Please note that the use of the GPT language model can be expensive due to its token usage. By utilizing this project, you acknowledge that you are responsible for monitoring and managing your own token usage and the associated costs. It is highly recommended to check your OpenAI API usage regularly and set up any necessary limits or alerts to prevent unexpected charges.

You can get a key here https://platform.openai.com/account/api-keys

* Keep in mind turbo model is cheaper. the OG gpt-4 model can be expensive, use carefully.

LogicSage needs an API key to make requests to OpenAI's API. Note that you will be charged by OpenAI for your API usage when hitting the send/"paperairplane" button.

Make sure to set usage limits! and keep an eye on your usage here:
- https://platform.openai.com/usage
- https://platform.openai.com/account/billing/limits

---
## Contact
Created by: Chris Dillard

Please raise Github issues or open a PR to discuss this project with me.

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
---
