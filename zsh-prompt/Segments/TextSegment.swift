//
//  PromptSegment.swift
//  zsh-prompt
//
//  Created by Ari Porad on 6/28/20.
//  Copyright © 2020 Ari Porad. All rights reserved.
//

import Foundation

struct TextSegment: Segment {
    let name: String;
    
    let text: String;
    let style: Style?;
    
    func generate(context: Context) -> SegmentOutcome {
        return .success(text: self.text, style: self.style)
    }
}

struct PrefixSuffixSegment: Segment {
    let segment: Segment;
    
    let prefix: String?;
    let suffix: String?
    
    var name: String { segment.name }
    
    init(segment: Segment, prefix: String?, suffix: String?) {
        self.segment = segment;
        self.prefix = prefix;
        self.suffix = suffix;
    }
    
    
    func generate(context: Context) -> SegmentOutcome {
        let outcome = segment.generate(context: context)
        
        switch outcome {
        case let .success(text, style):
            return .success(text: "\(self.prefix ?? "")\(text)\(self.suffix ?? "")", style: style)
        default:
            return outcome
        }
    }
}
