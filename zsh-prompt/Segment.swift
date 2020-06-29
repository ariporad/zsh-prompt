//
//  PromptSegment.swift
//  zsh-prompt
//
//  Created by Ari Porad on 6/25/20.
//  Copyright © 2020 Ari Porad. All rights reserved.
//

import Foundation


struct Context {
    let directory: URL;
}


enum SegmentOutcome: Error {
    case success(text: String, style: Style? = nil)
    case skip(reason: String, error: Error?)
    case fail(message: String, error: Error?)
}

// XXX: I don't like the duplication with SegmentOutcome
enum SegmentResult {
    case succeeded(segment: Segment, text: String, style: Style? = nil)
    case skipped(segment: Segment, reason: String, error: Error?)
    case failed(segment: Segment, message: String, error: Error?)
    
    static func from(outcome: SegmentOutcome, for segment: Segment) -> SegmentResult {
        switch outcome {
        case let .success(text, style):
            return .succeeded(segment: segment, text: text, style: style)
        case let .skip(reason, error):
            return .skipped(segment: segment, reason: reason, error: error)
        case let .fail(message, error):
            return .failed(segment: segment, message: message, error: error)
        }
    }
}

protocol Segment {
    var name: String { get }
    
    func generate(context: Context) throws -> SegmentOutcome;
}

extension Segment {
    func execute(context: Context) -> SegmentResult {
        var outcome: SegmentOutcome
        
        do {
            outcome = try self.generate(context: context)
        } catch {
            if let outcomeError = error as? SegmentOutcome {
                outcome = outcomeError
            } else {
                outcome = .fail(message: "Unknown Error \(error.localizedDescription)", error: error)
            }
        }
        
        return SegmentResult.from(outcome: outcome, for: self)
    }
}
