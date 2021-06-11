import Foundation
import SwiftUI
import SocketIO

enum SimpleValue {
    case string (String)
    case int (Int)
    case bool (Bool)
}

open class Socket {
    public static let `default` = Socket()
    private let manager: SocketManager
    private var socket: SocketIOClient
    var connecting = false
    var connected = false

    enum Status {
        case notConnected
        case connecting
        case connected
    }

    var status: Status {
        switch socket.status {
            case .connected:
                return .connected
            case .connecting:
                return .connecting
            case .notConnected, .disconnected:
                return .notConnected
        }
    }

    private init() {
        let url = "SET_ME"
        manager = SocketManager(
            socketURL: URL(string: url)!,
            config: [.log(false), .compress]
        )
        socket = manager.defaultSocket
    }

    func connect(_ callback: @escaping (Error?) -> Void) {
        if (status != .notConnected) { return }

        socket.once(clientEvent: .connect) { data, ack in
            print("socket connected")
            callback(nil)
        }

        socket.once(clientEvent: .disconnect) { data, ack in
            print("socket disconnected")
        }

        print("connect socket")
        socket.connect(timeoutAfter: 10) {
            print("socket connection timed out")

            self.socket.off(clientEvent: .connect)
            self.socket.off(clientEvent: .disconnect)

            callback(Error(
                name: "TimedoutError",
                message: "Connecting to the socket timed out",
                stack: "",
                reason: .connection
            ))
        }
    }

    func onConnect(_ callback: @escaping () -> Void) {
        socket.once(clientEvent: .connect) { data, ack in
            callback()
        }
    }

    func disconnect() {
        socket.disconnect()
    }

    func on(_ eventName: String, _ callback: @escaping (Any) -> Void) {
        socket.on(eventName) { data, ack in
            callback(data[0])
        }
    }

    func once(_ eventName: String, _ callback: @escaping (Any) -> Void) {
        socket.once(eventName) { data, ack in
            callback(data[0])
        }
    }

    func get(_ eventName: String, _ callback: @escaping (Error?, Any?) -> Void) {
        var errorId: UUID? = nil

        let eventId = socket.once(eventName) { [weak self] data, ack in
            if errorId != nil {
                self?.off(id: errorId!)
            }
            callback(nil, data[0])
        }
        errorId = socket.once("\(eventName):error") { [weak self] data, ack in
            self?.off(id: eventId)
            callback(self?.parseJSON(json: data[0] as! String), nil)
        }

        emit("get:\(eventName)")
    }

    func emit(_ eventName: String) {
        socket.emit(eventName)
    }

    func emit(_ eventName: String, _ arg: SocketData) {
        socket.emit(eventName, arg)
    }

    func off(_ eventName: String) {
        socket.off(eventName)
    }

    func off(id: UUID) {
        socket.off(id: id)
    }

    func parseJSON<T: Decodable>(json: String) -> T {
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: json.data(using: .utf8)!)
        } catch {
            fatalError("Couldn't parse data as \(T.self):\n\(error)")
        }
    }
}
