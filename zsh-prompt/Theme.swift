//
//  Theme.swift
//  zsh-prompt
//
//  Created by Ari Porad on 6/25/20.
//  Copyright © 2020 Ari Porad. All rights reserved.
//

import Foundation

// I (ariporad) have set $ARIPORAD_IS_XCODE = true in the Xcode Run Scheme to disable colors
let COLORS_ENABLED = (ProcessInfo.processInfo.environment["ARIPORAD_IS_XCODE"] != "true" && ProcessInfo.processInfo.environment["NO_COLORS"] != "true") || ProcessInfo.processInfo.environment["FORCE_COLORS"] == "true"

enum Style {
    case prompt
    case cwd
    case gitClean, gitDirty, gitUntrackedFiles, gitConflicted
    case error
}

struct Styling {
    let color: Color?;
    let background: Color?;
    let style: TextStyle?;
}

protocol Theme {
    var name: String { get }
    
    func getStyling(for style: Style) -> Styling?;
}

struct DefaultTheme: Theme {
    let name: String = "Default"
    
    func getStyling(for style: Style) -> Styling? {
        switch (style) {
        // Prompt
        case .prompt:            return nil;
        
        // DirectorySegment
        case .cwd:               return nil;
        
        
        // GitSegment
        case .gitClean:          return Styling(color: .blue , background: nil     , style: nil    )
        case .gitDirty:          return Styling(color: .black, background: .yellow , style: nil    )
        case .gitConflicted:     return Styling(color: .cyan , background: .blue   , style: .bold  )
        case .gitUntrackedFiles: return Styling(color: nil   , background: .green  , style: .blink )
        
        // Misc
        case .error:             return Styling(color: nil   , background: .magenta, style: .italic)
        }
    }
}

let currentTheme: Theme = DefaultTheme();

extension String.StringInterpolation {
    mutating func appendInterpolation(_ any: Any, style: Style?) {
        guard COLORS_ENABLED, let style = style, let styling = currentTheme.getStyling(for: style) else {
            return appendInterpolation("\(any)")
        }
        
        appendInterpolation("\(any, color: styling.color, background: styling.background, style: styling.style)")
    }
}
