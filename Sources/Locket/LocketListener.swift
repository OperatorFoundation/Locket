//
//  LocketListener.swift
//  
//
//  Created by Dr. Brandon Wiley on 8/8/22.
//

import Foundation

import TransmissionTypes

public struct LocketListener: TransmissionTypes.Listener
{
    let listener: TransmissionTypes.Listener

    public init(_ listener: TransmissionTypes.Listener)
    {
        self.listener = listener
    }

    public func accept() throws -> Connection
    {
        let connection = try self.listener.accept()

        return LocketConnection(connection, true)
    }

    public func close()
    {
        self.listener.close()
    }
}
