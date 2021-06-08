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

    func onReconnect(_ callback: @escaping () -> Void) {
        Socket.default.get("stores") { error, data in
            if error != nil {
                self.error = error!

                return
            }

            if self.modelData == nil { return }

            let categories: [Category] = Socket.default.parseJSON(json: data as! String)

            for category in categories {
                for store in category.stores {
                    self.updateItemsForStoreId(store.id, items: store.items)
                }
            }

            callback()
        }
    }

    func ensureConnection(_ callback: @escaping () -> Void) {
        if connected {
            callback()
        } else {
            print("ensuring socket connection before action")
            connect {
                self.onReconnect(callback)
            }
        }
    }

    func getStores() {
        if hasError(.stores) {
            clearError()
        }

        ensureConnection {
            Socket.default.get("stores") { error, data in
                if error == nil {
                    self.modelData?.categories = Socket.default.parseJSON(json: data as! String)
                } else {
                    self.error = error!
                }
            }
        }
    }

    func subscribeToItems() {
        Socket.default.on("items") { data in
            let dataDict = data as! [String: String]
            let storeId = dataDict["storeId"]!
            let itemsJson = dataDict["items"]!

            print("got store \(storeId) items: \(itemsJson)")

            if self.hasError(.items) {
                self.error = nil
            }

            if self.modelData != nil {
                self.updateItemsForStoreId(storeId, items: Socket.default.parseJSON(json: itemsJson))
            }
        }

        Socket.default.on("items:error") { data in
            self.error = Socket.default.parseJSON(json: data as! String)
        }
    }

    func unsubscribeToItems() {
        Socket.default.off("items")
        Socket.default.off("items:error")
    }

    func updateItemsForStoreId(_ storeId: String, items: [Item]) {
        let indices = self.modelData?.getIndicesByStoreId(storeId)

        if indices != nil {
            self.modelData!.categories[indices!.categoryIndex].stores[indices!.storeIndex].items = items
        }

    }

    func syncItems(_ storeDetailModel: StoreDetailModel, _ callback: @escaping () -> Void) {
        Socket.default.once("items") { data in
            callback()
        }

        ensureConnection {
            Socket.default.emit("sync:items", [
                "storeId": storeDetailModel.store.id,
                "parentId": storeDetailModel.store.parentId
            ])
        }
    }

    func addItem(_ storeDetailModel: StoreDetailModel) {
        ensureConnection {
            Socket.default.emit("add:item", [
                "storeId": storeDetailModel.store.id
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

    func deleteItem(_ storeDetailModel: StoreDetailModel, _ item: Item) {
        modelData?.deleteItem(storeDetailModel, item)

        ensureConnection {
            Socket.default.emit("delete:item", [
                "storeId": storeDetailModel.store.id,
                "itemId": item.id
            ])
        }

    }
}
