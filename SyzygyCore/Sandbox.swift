//
//  Sandbox.swift
//  SyzygyCore
//
//  Created by Dave DeLong on 12/31/17.
//  Copyright © 2017 Syzygy. All rights reserved.
//

import Foundation

public class Sandbox {
    
    public static let currentProcess: Sandbox = {
        let docs = try! FileManager.default.path(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let cache = try! FileManager.default.path(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let support = try! FileManager.default.path(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return Sandbox(documents: docs, caches: cache, support: support, defaults: UserDefaults.standard)
    }()
    
    public let documents: AbsolutePath
    public let caches: AbsolutePath
    public let support: AbsolutePath
    public let temporary: AbsolutePath
    public let logs: AbsolutePath
    
    public let defaults: UserDefaults
    
    public convenience init?(groupIdentifier: String) {
        let fm = FileManager.default
        
        guard let container = fm.containerURL(forSecurityApplicationGroupIdentifier: groupIdentifier) else { return nil }
        let docs = container.appendingPathComponent("Documents", isDirectory: true)
        let cache = container.appendingPathComponent("Caches", isDirectory: true)
        let supp = container.appendingPathComponent("Application Support", isDirectory: true)
        
        try? fm.createDirectory(at: docs, withIntermediateDirectories: true, attributes: nil)
        try? fm.createDirectory(at: cache, withIntermediateDirectories: true, attributes: nil)
        try? fm.createDirectory(at: supp, withIntermediateDirectories: true, attributes: nil)
        
        let defaults = UserDefaults(suiteName: groupIdentifier) !! "Cannot get defaults for \(groupIdentifier)"
        
        self.init(documents: AbsolutePath(docs),
                  caches: AbsolutePath(cache),
                  support: AbsolutePath(supp),
                  defaults: defaults)
    }
    
    public init(documents: AbsolutePath, caches: AbsolutePath, support: AbsolutePath, logs: AbsolutePath? = nil, defaults: UserDefaults) {
        self.documents = documents
        self.caches = caches
        self.support = support
        self.defaults = defaults
        
        self.logs = logs ?? support.appending(component: "Logs")
        try? FileManager.default.createDirectory(at: self.logs)
        
        self.temporary = AbsolutePath(fileSystemPath: NSTemporaryDirectory())
    }
    
    public func temporaryPath() -> TemporaryPath {
        return TemporaryPath(in: temporary)
    }
}
