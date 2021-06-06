import Foundation

final class RemoteData: ObservableObject {
    @Published var connected = false
    @Published var error: Error? = nil
    var modelData: ModelData? = nil

    func hasError(_ reason: Error.Reason) -> Bool {
        return error != nil && error!.reason == reason
    }

    func clearError() {
        error = nil
    }

    func connect() {
        connect(nil)
    }

    func connect(_ callback: (() -> Void)?) {
        if hasError(.connection) {
            clearError()
        }

        Socket.default.onDisconnect {
            self.connected = false
        }

        Socket.default.connect { error in
            if error == nil {
                self.connected = true
                if callback != nil {
                    callback!()
                }
            } else {
                self.error = error
            }
        }
    }

    func disconnect() {
        connected = false
        Socket.default.disconnect()
    }

    func ensureConnection (_ callback: @escaping () -> Void) {
        if connected {
            callback()
        } else {
            connect(callback)
        }
    }

    func getStores(_ callback: @escaping () -> Void) {
        if hasError(.stores) {
            clearError()
        }

        ensureConnection {
            Socket.default.get("stores") { anError, json in
                if anError == nil {
                    self.modelData?.categories = Socket.default.parseJSON(json: json!)
                } else {
                    self.error = anError!
                }

                callback()
            }
        }
    }

    func subscribeToItems(_ storeDetailModel: StoreDetailModel, _ callback: @escaping () -> Void) {
        Socket.default.on("\(storeDetailModel.store.id):items") { json in
            print("got items \(json)")

            if self.hasError(.items) {
                self.error = nil
            }

            if self.modelData != nil {
                self.modelData!.categories[storeDetailModel.categoryIndex].stores[storeDetailModel.storeIndex].items = Socket.default.parseJSON(json: json)
            }

            callback()
        }

        Socket.default.on("items:error") { json in
            self.error = Socket.default.parseJSON(json: json)
            callback()
        }

        ensureConnection {
            Socket.default.emit("get:items", storeDetailModel.store.id)
        }
    }

    func unsubscribeToItems(_ storeDetailModel: StoreDetailModel) {
        Socket.default.off("\(storeDetailModel.store.id):items")
        Socket.default.off("items:error")
    }

    func syncItems(_ storeDetailModel: StoreDetailModel) {
        ensureConnection {
            Socket.default.emit("sync:items", [
                "storeId": storeDetailModel.store.id,
                "parentId": storeDetailModel.store.parentId
            ])
        }
    }

    func updateItem(_ storeDetailModel: StoreDetailModel, _ item: Item) {
        modelData?.updateItem(storeDetailModel, item)

        ensureConnection {
            Socket.default.emit("update:item", [
                "storeId": storeDetailModel.store.id,
                "item": [
                    "id": item.id,
                    "name": item.name,
                    "isChecked": item.isChecked
                ]
            ])
        }
    }
}
