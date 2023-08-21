//
//  XcodeProjHandler.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 8/17/23.
//

import Foundation
import XcodeProj
import PathKit

func processXcodeProject(path: String) throws -> [FileSystemItem] {
   // let projectPath = URL(fileURLWithPath: path)
    let project = try XcodeProj(path: Path(path))
    guard let mainGroup = project.pbxproj.rootObject?.mainGroup else {
         print("fail")
        throw XCodeProjError.notFound(path: Path(path))
    }
    return processGroup(pbGroup: mainGroup)
}

func processGroup(pbGroup: PBXGroup) -> [FileSystemItem] {
    guard let children = pbGroup.children as? [PBXFileElement] else {
        return []
    }

    return children.compactMap { child in
        if let file = child as? PBXFileReference {
            return FileSystemItem(name: file.name ?? file.path ?? "Untitled", isDirectory: false, children: nil)
        }

        if let group = child as? PBXGroup {
            return FileSystemItem(name: group.name ?? group.path ?? "Unnamed Group", isDirectory: true, children: processGroup(pbGroup: group))
        }

        return nil
    }
}
