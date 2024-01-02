//
//  ProjectHierarchyView.swift
//  LogicSage
//
//  Created by Chris Dillard on 8/17/23.
//

import Foundation
import SwiftUI

struct ProjectHierarchyView: View {
    let project: Project // Assuming you have a Project model with a FileSystemItem property
    var body: some View {
        ScrollView {

            HStack(alignment:.firstTextBaseline) {
                Image(systemName:  "square.topthird.inset.filled")
                    .resizable()
                    .padding(.top,16)
                    .frame(width: 16, height: 15)
                Text(project.name)
                    .lineLimit(1)
                    .font(.caption)
            }

            VStack(alignment: .leading, spacing: 0) {
                if project.fileSystemItems.isEmpty {
                    Text("Please select xcodeproj.")
                        .font(.caption)
                        .lineLimit(1)

                        .padding(.top,20)

                }
                else {
                    ForEach(project.fileSystemItems, id: \.id) { item in
                        ProjectHierarchyRow(item: item)
                    }
                }
            }
        }
    }
}

struct ProjectHierarchyRow: View {
    let item: FileSystemItem
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let children = item.children {
#if !os(tvOS)

                    DisclosureGroup(content: {
                        ForEach(children, id: \.id) { child in
                            ProjectHierarchyRow(item: child)
                        }
                    }, label: {
                        HStack(alignment:.firstTextBaseline) {
                            Image(systemName: "folder.fill")
                                .resizable()
                                .padding(.top,2)
                                .frame(width: 16, height: 15)
                            Text(item.name)
                                .lineLimit(1)

                                .font(.caption)
                        }

                    })
                    .padding(.leading,2)
                #endif
            } else {

                Button {
                    print("selected file with name=\(item.name)")
                } label : {

                    HStack(alignment: .firstTextBaseline) {
                        Image(systemName: "swift")
                            .resizable()
                            .frame(width: 16, height: 15)
                            .padding(.leading,2)

                        Text(item.name)
                            .font(.caption)
                            .lineLimit(1)

                            .padding(.leading,2)
                        Spacer()
                    }
                }
            }
        }
        .padding()
    }
}
