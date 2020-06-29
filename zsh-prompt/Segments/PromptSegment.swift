//
//  PromptSegment.swift
//  zsh-prompt
//
//  Created by Ari Porad on 6/28/20.
//  Copyright © 2020 Ari Porad. All rights reserved.
//

import Foundation

struct PromptSegment: Segment {
    var name: String = "prompt"
    
    func generate(context: Context) throws -> SegmentOutcome {
        return .success(text: "$", style: .prompt)
    }
    
    
}
