//
//  LocketConnection.swift
//  
//
//  Created by Dr. Brandon Wiley on 8/8/22.
//

import Foundation
import Logging
import SystemPackage

import Gardener
import SwiftHexTools
import TransmissionTypes

public struct LocketConnection: TransmissionTypes.Connection
{
    let connection: TransmissionTypes.Connection
    var fd: FileDescriptor? = nil

    public init(_ connection: TransmissionTypes.Connection, _ accepting: Bool = false)
    {
        self.connection = connection

        let base = File.applicationSupportDirectory()

        let locketDirectory = base.appendingPathComponent("locket")
        if !File.exists(locketDirectory.path)
        {
            let _ = File.makeDirectory(url: locketDirectory)
        }

        let uuid = UUID()
        let logpath: FilePath = FilePath("\(base.path)/locket/\(uuid.uuidString)/")

        do
        {
            self.fd = try FileDescriptor.open(logpath, .writeOnly, options: [.append, .create], permissions: .ownerReadWrite)
        }
        catch
        {
            print("Failed to initialize Locket, falling through to passthrough mode: \(error)")
            return
        }

        if accepting
        {
            self.log("accepting \(connection)")
        }
        else
        {
            self.log("connecting \(connection)")
        }
    }

    public func read(size: Int) -> Data?
    {
        let result = self.connection.read(size: size)

        if let result = result
        {
            if let string = String(data: result, encoding: .utf8)
            {
                self.log("read(size: \(size)): \"\(string)\" - \(result.count) - \(result.hex)")
            }
            else
            {
                self.log("read(size: \(size)): \(result.count) - 0x\(result.hex)")
            }
        }
        else
        {
            self.log("read(size: \(size)): nil")
        }

        return result
    }

    public func read(maxSize: Int) -> Data?
    {
        let result = self.connection.read(maxSize: maxSize)

        if let result = result
        {
            if let string = String(data: result, encoding: .utf8)
            {
                self.log("read(maxSize: \(maxSize)): \"\(string)\" - \(result.count) - \(result.hex)")
            }
            else
            {
                self.log("read(maxSize: \(maxSize)): \(result.count) - 0x\(result.hex)")
            }
        }
        else
        {
            self.log("read(maxSize: \(maxSize)): nil")
        }

        return result
    }

    public func readWithLengthPrefix(prefixSizeInBits: Int) -> Data?
    {
        let result = self.connection.readWithLengthPrefix(prefixSizeInBits: prefixSizeInBits)

        if let result = result
        {
            if let string = String(data: result, encoding: .utf8)
            {
                self.log("readWithLengthPrefix(prefixSizeInBits: \(prefixSizeInBits)): \"\(string)\" - \(result.count) - \(result.hex)")
            }
            else
            {
                self.log("readWithLengthPrefix(prefixSizeInBits: \(prefixSizeInBits)): \(result.count) - 0x\(result.hex)")
            }
        }
        else
        {
            self.log("readWithLengthPrefix(prefixSizeInBits: \(prefixSizeInBits)): nil")
        }

        return result
    }

    public func write(data: Data) -> Bool
    {
        let result = self.connection.write(data: data)

        if let string = String(data: data, encoding: .utf8)
        {
            self.log("write(data: \"\(string)\"): \(data.count) - \(data.hex) - \(result)")
        }
        else
        {
            self.log("write(data: 0x\(data.hex)): \(data.count) - \(data.hex) - \(result)")
        }

        return result
    }

    public func write(string: String) -> Bool
    {
        let result = self.connection.write(string: string)

        self.log("write(string: \"\(string)\"): \(string.count) - \(string.data.hex) - \(result)")

        return result
    }

    public func writeWithLengthPrefix(data: Data, prefixSizeInBits: Int) -> Bool
    {
        let result = self.connection.writeWithLengthPrefix(data: data, prefixSizeInBits: prefixSizeInBits)

        if let string = String(data: data, encoding: .utf8)
        {
            self.log("writeWithLengthPrefix(data: \"\(string)\", prefixSizeInBits: \(prefixSizeInBits)): \(data.count) - \(data.hex) - \(result)")
        }
        else
        {
            self.log("writeWithLengthPrefix(data: 0x\(data.hex), prefixSizeInBits: \(prefixSizeInBits)): \(data.count) - \(data.hex) - \(result)")
        }

        return result
    }

    public func close()
    {
        self.connection.close()

        if let fd = self.fd
        {
            do
            {
                try fd.close()
            }
            catch
            {
                return
            }
        }
    }

    func log(_ string: String)
    {
        if Locket.print
        {
            print(string)
        }

        if let fd = self.fd
        {
            do
            {
                try fd.writeAll(string.utf8)
                try fd.writeAll("\n".utf8)
            }
            catch
            {
                return
            }
        }
    }
}
