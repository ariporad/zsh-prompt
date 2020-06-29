//
//  Git.swift
//  zsh-prompt
//
//  Created by Ari Porad on 6/25/20.
//  Copyright © 2020 Ari Porad. All rights reserved.
//

import Foundation

struct GitSegment: Segment {
    let name = "git"
    
    private struct Status: Hashable, Comparable {
        let priority: UInt32;
        
        let symbol: String?;
        let style: Style?;
        
        public static let clean          = Status(priority: 0, symbol: nil, style: .gitClean)
        public static let dirty          = Status(priority: 1, symbol: "*", style: .gitDirty)
        public static let untrackedFiles = Status(priority: 2, symbol: "+", style: .gitUntrackedFiles)
        public static let conflicted     = Status(priority: 3, symbol: "!", style: .gitConflicted)

        public static let error          = Status(priority: 98, symbol: "¡", style: .error)
        public static let unknown        = Status(priority: 99, symbol: "¿", style: .error)
        
        public static func from(rawStatus: Diff.Status) -> Status {
            switch rawStatus {
            case .current, .ignored: return .clean
            case .indexNew, .indexModified, .i◊ndexDeleted, .indexRenamed, .indexTypeChange: return .dirty
            case .workTreeModified, .workTreeDeleted, .workTreeTypeChange, .workTreeRenamed: return .dirty
            case .workTreeNew: return .untrackedFiles
            case .conflicted: return .conflicted
            case .workTreeUnreadable: return .error
            default: return .unknown
            }
        }
        
        static func < (lhs: GitSegment.Status, rhs: GitSegment.Status) -> Bool {
            lhs.priority < rhs.priority
        }
    }
    

    
    func generate(context: Context) throws -> SegmentOutcome  {
        try skip(Repository.isValid(url: context.directory), reason: "No git repo in directory")
        
        let repo = try fail(Repository.at(context.directory), message: "Couldn't open repository")
        
        let latestCommit = try fail(repo.HEAD(), message: "Couldn't get HEAD");
        let branchName = latestCommit.shortName ?? String(latestCommit.oid.description.prefix(7))
        
        let statusEntries = (try fail(repo.status(), message: "Couldn't check repo status"))
        
        print(statusEntries.count)
        print(statusEntries)
        
        let rawStatuses = statusEntries.map { $0.status }
            
        var status: Set<Status> = Set([])
        
        print(rawStatuses)
        
        for rawStatus in rawStatuses {
            let newStatus = Status.from(rawStatus: rawStatus)
            status.update(with: newStatus)
        }
        
        let symbols = status.sorted(by: <).map { $0.symbol ?? "" }.joined(separator: "")
        let style = status.sorted(by: >).first { $0.style != nil }?.style
        
        return SegmentOutcome.success(text: "\(branchName)\(symbols)", style: style)
        
       
        // TODO: handle statusEntrys
//        var status: Set<Status> = Set()
//
//        statusEntrys.forEach {
//            switch $0.status {
//            case .current: return
//            case .ignored
//            }
//        }
        
    }
}


