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

    private init() {
        let url = "SET_ME"
        manager = SocketManager(
            socketURL: URL(string: url)!,
            config: [.log(false), .compress]
        )
        socket = manager.defaultSocket
    }

    func connect(_ callback: @escaping (Error?) -> Void) {
        if (connecting || connected) { return }

        connecting = true

        socket.once(clientEvent: .connect) { data, ack in
            print("socket connected")
            self.connecting = false
            self.connected = true
            callback(nil)
        }

        onDisconnect {
            print("socket disconnected")
            self.connecting = false
            self.connected = false
        }

        print("connect socket")
        socket.connect(timeoutAfter: 20) {
            print("socket connection timed out")
            self.connecting = false
            self.connected = false

            callback(Error(
                name: "TimedoutError",
                message: "Connecting to the socket timed out",
                stack: "",
                reason: .connection
            ))
        }
    }

    func disconnect() {
        if !connected { return }

        socket.disconnect()
        connected = false
    }

    func onDisconnect (_ callback: @escaping () -> Void) {
        socket.once(clientEvent: .disconnect) { data, ack in
            callback()
        }
    }

    @discardableResult
    func on(_ eventName: String, _ callback: @escaping (String) -> Void) -> UUID {
        socket.on(eventName) { data, ack in
            callback(data[0] as! String)
        }
    }

    @discardableResult 
    func once(_ eventName: String, _ callback: @escaping (String) -> Void) -> UUID {
        socket.once(eventName) { data, ack in
            callback(data[0] as! String)
        }
    }

    func get(_ eventName: String, _ callback: @escaping (Error?, String?) -> Void) {
        var errorId: UUID? = nil

        let eventId = once(eventName) { [weak self] result in
            if errorId != nil {
                self?.off(id: errorId!)
            }
            callback(nil, result)
        }
        errorId = once("\(eventName):error") { [weak self] error in
            self?.off(id: eventId)
            callback(Socket.default.parseJSON(json: error), nil)
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
