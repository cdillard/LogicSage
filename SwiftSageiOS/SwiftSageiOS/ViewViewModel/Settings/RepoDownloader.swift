//
//  RepoDownloader.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 5/7/23.
//

import Foundation

func getTotalFileCount(_ rootFile: GitHubContent?, _ files: [GitHubContent]) -> Int {
    var count = 0
    for file in files {
        if file.type == "file" {
            count += 1
        } else if file.type == "dir", let children = file.children, !children.isEmpty {
            count += getTotalFileCount(file, children)
        }
    }
    return count
}

func downloadAndStoreFiles(_ rootFile: GitHubContent?, _ files: [GitHubContent], accessToken: String, completionHandler: @escaping (Result<Void, Error>) -> Void) {
    let operationQueue = OperationQueue()
    operationQueue.maxConcurrentOperationCount = 5

    let documentsDirectory = getDocumentsDirectory()
    var fDex = 0

    let totalFiles = getTotalFileCount(rootFile, files)

    var operations: [Operation] = []
    for file in files {
        let operation = BlockOperation {
            if file.type == "file", let downloadUrl = file.downloadUrl {
                var request = URLRequest(url: URL(string: downloadUrl)!)
                request.setValue("token \(accessToken)", forHTTPHeaderField: "Authorization")

                let semaphore = DispatchSemaphore(value: fDex)

                URLSession.shared.dataTask(with: request) { data, response, error in

                    if let error = error {
                        completionHandler(.failure(error))
                        semaphore.signal()
                        return
                    }

                    guard let data = data else {
                        logD("error writing file: DownloadError")
                        completionHandler(.failure(NSError(domain: "DownloadError", code: -1, userInfo: nil)))
                        semaphore.signal()
                        return
                    }

                    let fileURL = documentsDirectory.appendingPathComponent(SettingsViewModel.shared.gitUser).appendingPathComponent(SettingsViewModel.shared.gitRepo).appendingPathComponent(SettingsViewModel.shared.gitBranch).appendingPathComponent(file.path)
                    do {
                        try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
                        try data.write(to: fileURL)

                        fDex += 1

                        logD("Wrote (\(fDex)/\(totalFiles)): \(fileURL)")

                    } catch {
                        logD("error writing file: \(error)")
                        completionHandler(.failure(error))
                        semaphore.signal()
                        return
                    }
                    semaphore.signal()
                }.resume()

                semaphore.wait()
            }
            else if file.type == "dir" && file.children?.isEmpty == false {

                let childArr = file.children ?? []

                let semaphore = DispatchSemaphore(value: 0)
                downloadAndStoreFiles(file, childArr, accessToken: SettingsViewModel.shared.ghaPat) { success in
                    switch success {
                    case .success(_):
                        break
                    case .failure(let error):
                        logD("Error download of dir children.error =  \(error)!")
                        completionHandler(.failure(error))
                        semaphore.signal()
                        return
                    }
                    semaphore.signal()
                }
                semaphore.wait()
            }
        }

        operationQueue.addOperation(operation)
        operations.append(operation)
    }

    let completionOperation = BlockOperation {
        DispatchQueue.main.async {
            completionHandler(.success(()))
        }
    }

    operations.forEach { completionOperation.addDependency($0) }
    OperationQueue.main.addOperation(completionOperation)
}




//func downloadAndStoreFiles(_ rootFile: GitHubContent?, _ files: [GitHubContent], accessToken: String, completionHandler: @escaping (Result<Void, Error>) -> Void) {
//    let dispatchGroup = DispatchGroup()
//    let documentsDirectory = getDocumentsDirectory()
//    var fDex = 0
//    for file in files {
//        dispatchGroup.enter()
//
//        if file.type == "file", let downloadUrl = file.downloadUrl {
//
//            var request = URLRequest(url: URL(string: downloadUrl)!)
//            request.setValue("token \(accessToken)", forHTTPHeaderField: "Authorization")
//
//            DispatchQueue.main.asyncAfter(deadline: .now() + githubDelay) {
//
//                URLSession.shared.dataTask(with: request) { data, response, error in
//                     defer { dispatchGroup.leave() }
//
//                    if let error = error {
//                        completionHandler(.failure(error))
//                        return
//                    }
//
//                    guard let data = data else {
//                        logD("error writing file: DownloadError")
//                        completionHandler(.failure(NSError(domain: "DownloadError", code: -1, userInfo: nil)))
//                        return
//                    }
//
//                    let fileURL = documentsDirectory.appendingPathComponent(SettingsViewModel.shared.gitUser).appendingPathComponent(SettingsViewModel.shared.gitRepo).appendingPathComponent(SettingsViewModel.shared.gitBranch).appendingPathComponent(file.path)
//                    do {
//                        try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
//                        try data.write(to: fileURL)
//
//                        fDex += 1
//
//                        logD("Wrote (\(fDex)/\(files.count)): \(fileURL)")
//
//                    } catch {
//                        logD("error writing file: \(error)")
//                        completionHandler(.failure(error))
//                        return //completionHandler(.failure(error))
//                    }
//                }.resume()
//            }
//
//        }
//        else if file.type == "dir" && file.children?.isEmpty == false {
//            let childArr = file.children ?? []
////            logD("Downloading \(childArr.count) files from child dir...")
//            DispatchQueue.main.asyncAfter(deadline: .now() + githubDelay + Double(Float.random(in: Float(githubDelay)...Float(githubDelay + 2)))) {
//                fDex += 1
//
//                downloadAndStoreFiles(file, childArr, accessToken: SettingsViewModel.shared.ghaPat) { success in
//                    defer { dispatchGroup.leave() }
//                    switch success {
//                    case .success(_):
////                        logD("Successful download of dir children.")
//                        break
//                    case .failure(let error):
//
//                        logD("Error download of dir children.error =  \(error)!")
//                        completionHandler(.failure(error))
//                        return //completionHandler(.failure(error))
//                    }
//                }
//            }
//        }
//        else {
//            dispatchGroup.leave()
//
//        }
//    }
//
//    dispatchGroup.notify(queue: .main) {
//        completionHandler(.success(()))
//    }
//}
