//
//  Helpers.swift
//  zsh-prompt-app
//
//  Created by Ari Porad on 6/27/20.
//  Copyright © 2020 Ari Porad. All rights reserved.
//

import Foundation

func fail<S, F: Error>(_ result: Result<S, F>, message: String) throws -> S {
    switch result {
    case .failure(let error):
        throw SegmentOutcome.fail(message: message, error: error)
    case .success(let result):
        return result
    }
}

func skip<S, F: Error>(_ result: Result<S, F>, reason: String) throws -> S {
    switch result {
    case .failure(let error):
        throw SegmentOutcome.skip(reason: reason, error: error)
    case .success(let result):
        return result
    }
}
