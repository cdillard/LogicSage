//
//  Prompt.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/12/23.
//

var builtInAppDesc = "that grabs the latest headlines from nytimes.com via google results and displays them in aesthetically pleasing arranged views"
var appDesc = builtInAppDesc

func promptText(noGoogle: Bool = true, noLink: Bool = true) -> String {

    let googleStringInclude = !noGoogle ? "{\"command\": \"Google\",\"name\": \"EXC_BAD_ACCESS\"}," : ""

    let googleString =
    """
    - The Google query command can be used if you need help or to look up any bugs you encounter, this way you can find fixes on sites like stackoverflow.com. (In the example above EXC_BAD_ACCESS represents the search term you want more info for or the failing line you are trying to fix. I will reply with a message containing the search results in a JSON array below "Search Results:"
    """

    let linkStringInclude = !noLink ? "{\"command\": \"Link\",\"name\": \"www.nytimes.com\"}," : ""
    let linkString =
    """
    - The Link url command can be used to get more information by accessing a link. Pass the link: {\"command\": \"Link\",\"name\": \"www.nytimes.com\"}. I will reply with a message containing the text from the link.
    """
    return """
    Develop an iOS app in \(language) for a SwiftUI-based \(appDesc). Name it \(aiNamedProject ? "a unique name" : appName). Return necessary, valid, and formatted Swift code files as a JSON array. It is essential you return your response as a JSON array matching the structure:. [\(googleStringInclude)\(linkStringInclude){"command": "Create project","name": "UniqueName"}, {"command": "Create file","name": "Filename.swift","fileContents": "SWIFT_FILE_CONTENTS"}, {"command": "Open project", "name": "\(aiNamedProject ? "UniqueName" : appName)"},{"command": "Close project", "name": "UniqueName"}]
    Example SWIFT_FILE_CONTENTS = "import SwiftUI\\nstruct UniqueGameView: View { var body: some View { Spinner() } }\nstruct Spinner: View { var body: some View {a } }". Follow this order: Google, Link, Create project, Create Swift files (including App file), Open project, Close project. Minimize command usage.
    - It is essential you return your response as a JSON array.
    - It is essential you include a Swift `App` file.
    \(!noGoogle ? googleString : "")
    \(!noLink ? linkString : "")
    - Implement all needed code. Do not use files other than .swift files. Use Swift and SceneKit. Do not use .scnassets folders or .scnassets files or .scn files.

    """
}

var prompt = promptText()

let fixItPrompt = """

Review the following Swift source code:

"""

let errorsPrompt = """

Review Errors: Encountered

"""

func includeFilesPrompt() -> String {
"""

Please suggest improvements and corrections to fix the errors and optimize the code. Return necessary, valid, and formatted Swift code files as a JSON array. It is essential you return your response as a JSON array matching the structure:. [{"command": "Create Project","name": "\(projectName)"}, {"command": "Create file","name": "Filename.swift","fileContents": "import SwiftUI\\nstruct UniqueGameView: View { var body: some View { Spinner() } }\nstruct Spinner: View { var body: some View {a } }"}, {"command": "Open project", "name": "\(projectName)"},{"command": "Close project", "name": "\(projectName)"}]

Available commands: Create files, Open project, Close project. Minimize command usage.

Source Code:

"""
}

func refreshPrompt(appDesc: String) {
    updatePrompt(appDesc2: appDesc)
    updateOpeningLine()
}

func updatePrompt(appDesc2: String) {
    appDesc = appDesc2
    prompt = promptText(noGoogle: !enableGoogle, noLink: !enableLink)
}



let searchResultHeading = """

Search Results:

"""


// Nex't w'll consider adding source code summarization when passing it back and forth aka

// fileContents is substituted with this format placeholder.

// [SymbolDetail.swift source code]

// [Symbol.swift source code]
