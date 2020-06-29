//
//  main.swift
//  zsh-prompt
//
//  Created by Ari Porad on 6/22/20.
//  Copyright © 2020 Ari Porad. All rights reserved.
//

import Foundation

let SEGMENTS: [Segment] = [
    GitSegment(),
]

let context = Context(directory: URL(fileURLWithPath: "/Users/ariporad/dev/zsh-prompt/test", isDirectory: true))

let results = SEGMENTS.map { $0.execute(context: context) }

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
