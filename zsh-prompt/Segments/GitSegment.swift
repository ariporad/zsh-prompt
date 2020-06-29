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
    
    private struct Status: Hashable, Comparable, CustomStringConvertible {
        let priority: UInt32;
        
        let symbol: String?;
        let style: Style?;
        
        public static let clean          = Status(priority: 0, symbol: nil, style: .gitClean)
        public static let dirty          = Status(priority: 1, symbol: "*", style: .gitDirty)
        public static let untrackedFiles = Status(priority: 2, symbol: "+", style: .gitUntrackedFiles)
        public static let unmerged       = Status(priority: 3, symbol: "!", style: .gitConflicted)

        public static let error          = Status(priority: 98, symbol: "¡", style: .error)
        public static let unknown        = Status(priority: 99, symbol: "¿", style: .error)
        
        static func < (lhs: GitSegment.Status, rhs: GitSegment.Status) -> Bool {
            lhs.priority < rhs.priority
        }
        
        public var description: String { "(GitSegment.Status: \(self.symbol ?? "<None>"), P: \(self.priority))" }
        
        /*
         o   ' ' = unmodified
         o   M = modified

         o   A = added

         o   D = deleted

         o   R = renamed

         o   C = copied

         o   U = updated but unmerged
         */
        
        static func from(changeSignifier: Character) -> Status? {
            switch changeSignifier {
            case "M", "A", "D", "R", "C": return .dirty
            case " ": return .clean
            case "?": return .untrackedFiles
            case "U": return .unmerged
            default:  return .unknown
            }
        }
        

    }

    private struct GitStatusOutput {
        let branchName: String;
        let status: [Status];
        
        var symbols: String { status.compactMap { $0.symbol }.joined() }
        
        var effectiveStyle: Style? { status.last { $0.style != nil }?.style }
        
        // This method has lots of room for optimization if we need it
        init?(stdout: String) {
            var lines = stdout.split(separator: "\n")
            
            self.branchName = String(lines.removeFirst().split(separator: " ")[1])
            
            var status: Set<Status> = []
            
            for line in lines {
                let changeSignifier = line.prefix(2)
                guard changeSignifier.count == 2 else { continue }
                
                for char in changeSignifier {
                    guard let newStatus = Status.from(changeSignifier: char) else { continue }
                    status.update(with: newStatus)
                }
            }

            // Unmerged trumps everything else, because all other statuses have different meanings in a merge
            // that we don't want to deal with
            if status.contains(.unmerged) {
                self.status = [.unmerged]
            } else {
                self.status = status.sorted(by: <)
            }
        }
    }
    
    func runGitStatus(path: URL) -> String? {
        let stdout = Pipe()
        let proc = Process()
        
        proc.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        proc.arguments = ["git", "status", "--porcelain=v1", "-b"]
        proc.currentDirectoryURL = path
        proc.standardOutput = stdout
        
        guard (try? proc.run()) != nil else { return nil }
        
        return String(decoding: stdout.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
    }
    
    func generate(context: Context) throws -> SegmentOutcome  {
        guard let statusOutput = runGitStatus(path: context.directory) else { return .fail(message: "Couldn't run git status", error: nil) }
        
        guard let parsedStatus = GitStatusOutput(stdout: statusOutput) else { return .fail(message: "Couldn't parse git status output", error: nil) }
        
        return .success(text: "\(parsedStatus.branchName)\(parsedStatus.symbols)", style: parsedStatus.effectiveStyle)
    }
}


