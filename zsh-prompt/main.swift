//
//  main.swift
//  zsh-prompt
//
//  Created by Ari Porad on 6/22/20.
//  Copyright © 2020 Ari Porad. All rights reserved.
//

import Foundation

// Set this to nil to run in CWD, or to a path
let DEBUG_FORCE_PATH: String? = "/Users/ariporad/dev/zsh-prompt-3/zsh-prompt/test"
let DEBUG_OUTPUT: Bool = false;

let SEGMENTS: [Segment] = [
    PrefixSuffixSegment(segment: GitSegment(), prefix: "[", suffix: "]"),
    TextSegment(name: "prompt", text: "$", style: .prompt)
]

let context = Context(directory: URL(fileURLWithPath: DEBUG_FORCE_PATH ?? FileManager.default.currentDirectoryPath, isDirectory: true))

let results = SEGMENTS.map { $0.execute(context: context) }

if (DEBUG_OUTPUT) {
    print("Running in: \(context.directory.path)")

    for case let .skipped(segment, reason, error) in results {
        print("Segment Skipped: \(segment.name): \(reason) (\(error?.localizedDescription ?? "No Error")")
    }

    for case let .failed(segment, message, error) in results {
        print("Segment Failed: \(segment.name): \(message): \(error?.localizedDescription ?? "Unknown Error")")
    }

    for case let .succeeded(segment, text, style) in results {
        print("Segment Succeeded: \(segment.name): \(text, style: style)")
    }
} else {
    for case let .failed(segment, message, _) in results {
        print("\("Error: Segment \(segment.name) failed! \(message)", style: .error)")
    }

    for case let .succeeded(_, text, style) in results {
        print("\(text, style: style) ", separator: "", terminator: "")
    }
    
    // In Xcode, it's not obvious where the prompt ends (trailing spaces, etc), so we add something to the end.
    // NB: $ARIPORAD_IS_XCODE = true is set in my run scheme.
    if (ProcessInfo.processInfo.environment["ARIPORAD_IS_XCODE"] == "true") {
        print("command", separator: "", terminator: "\n")
    }
}
