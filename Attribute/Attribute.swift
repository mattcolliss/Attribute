//
//  Attribute.swift
//  Attribute
//
//  Created by Matthew.Colliss on 10/04/2018.
//

import Foundation

struct Pod {
    let name: String
    let version: String
    let license: String
}

class Attribute {

    private let path = FileManager.default.currentDirectoryPath

    func generate() {
        let podfileLock = readPodfileLock()
        let pods = parsePods(from: podfileLock)
        print(pods)
    }

    private func readPodfileLock() -> String {

        let podfileLockPath = path.appending("/Podfile.lock")

        let podfileLock: String

        do {
            podfileLock = try String(contentsOfFile: podfileLockPath)
        } catch {
            print(error)
            exit(EXIT_FAILURE)
        }

        return podfileLock

    }

    private func parsePods(from podfileLock: String) -> [Pod] {

        func parseNameAndVersion(_ line: String) -> (String, String)? {
            let components = line.components(separatedBy: " ")
            guard components.count > 4 else { return nil }
            let name = components[3]
            let version = components[4].replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "")
            return (name, version)
        }

        func readLicense(forPodNamed podName: String) -> String? {
            let licensePath = path + "/Pods/" + podName + "/LICENSE"
            let license = try? String(contentsOfFile: licensePath)
            return license
        }

        var pods = [Pod]()

        podfileLock.enumerateLines { (line, stop) in

            if line.isEmpty {
                stop = true
                return
            }

            if line.hasPrefix("  - "), let (name, version) = parseNameAndVersion(line), let license = readLicense(forPodNamed: name) {
                let pod = Pod(name: name, version: version, license: license)
                pods.append(pod)
            }

        }

        return pods

    }

}
