//
//  DirectorySegment.swift
//  zsh-prompt
//
//  Created by Ari Porad on 6/28/20.
//  Copyright © 2020 Ari Porad. All rights reserved.
//

import Foundation

struct DirectorySegment: Segment {
    let name: String = "directory"
    
    func generate(context: Context) -> SegmentOutcome {
        let homeDir = FileManager.default.homeDirectoryForCurrentUser;
        var cwd = context.directory;
        if (cwd.pathComponents.starts(with: homeDir.pathComponents)) {
            let components = cwd.pathComponents.dropFirst(homeDir.pathComponents.count)
            cwd = URL(fileURLWithPath: "~")
            components.forEach { cwd.appendPathComponent($0) }
        }
        
        return .success(text: cwd.relativePath, style: .cwd)
    }
}
