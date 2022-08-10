//
//  Locket.swift
//  
//
//  Created by Dr. Brandon Wiley on 8/8/22.
//

import Foundation
import Logging

import Gardener

public class Locket
{
    static public var print: Bool = false

    static public func getLogs() -> [UUID]
    {
        let base = File.applicationSupportDirectory()

        let locketDirectory = base.appendingPathComponent("locket")
        if !File.exists(locketDirectory.path)
        {
            return []
        }

        guard let results = File.contentsOfDirectory(atPath: locketDirectory.path) else
        {
            return []
        }

        return results.compactMap { return UUID(uuidString: $0) }
    }

    static public func getLog(_ uuid: UUID) -> String?
    {
        let base = File.applicationSupportDirectory()

        let locketDirectory = base.appendingPathComponent("locket")
        if !File.exists(locketDirectory.path)
        {
            return nil
        }

        let logpath = locketDirectory.appendingPathComponent(uuid.uuidString)
        if !File.exists(logpath.path)
        {
            return nil
        }

        return try? String(contentsOfFile: logpath.path)
    }

    static public func clear()
    {
        let base = File.applicationSupportDirectory()

        let locketDirectory = base.appendingPathComponent("locket")
        if File.exists(locketDirectory.path)
        {
            let _ = File.delete(atPath: locketDirectory.path)
        }
    }
}
