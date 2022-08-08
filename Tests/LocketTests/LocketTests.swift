import Foundation
import XCTest

@testable import Locket
import Transmission

final class LocketTests: XCTestCase
{
    func testTransmission()
    {
        guard let listener = TransmissionListener(port: 1234, logger: nil) else
        {
            XCTFail()
            return
        }

        Task
        {
            let connection = listener.accept()
            let _ = connection.read(size: 4)
            let _ = connection.write(string: "abcd")
//            connection.close()
        }

        guard let connection = TransmissionConnection(host: "127.0.0.1", port: 1234) else
        {
            XCTFail()
            return
        }
        let _ = connection.write(string: "1234")
        let _ = connection.read(size: 4)
//        connection.close()
    }

    func testLocket() throws
    {
        Locket.clear()

        guard let listener = TransmissionListener(port: 1234, logger: nil) else
        {
            XCTFail()
            return
        }
        let locketListener = LocketListener(listener)

        Task
        {
            do
            {
                let connection = try locketListener.accept()
                let _ = connection.read(size: 4)
                let _ = connection.write(string: "abcd")
//                connection.close()
            }
            catch
            {
                return
            }
        }

        guard let connection = TransmissionConnection(host: "127.0.0.1", port: 1234) else
        {
            XCTFail()
            return
        }
        let locketConnection = LocketConnection(connection)
        let _ = locketConnection.write(string: "1234")
        let _ = locketConnection.read(size: 4)
//        locketConnection.close()

        let logs = Locket.getLogs()
        XCTAssertEqual(logs.count, 2)

        for uuid in logs
        {
            guard let log = Locket.getLog(uuid) else
            {
                XCTFail()
                return
            }

            print(uuid.uuidString)
            print("------------------")
            print(log, terminator: "")
            print("==================")
        }
    }
}
