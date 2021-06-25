import Foundation

final class RemoteData: ObservableObject {
    @Published var status = Socket.Status.notConnected
    @Published var error: Error? = nil
    @Published var debug = UserDefaults.standard.bool(forKey: "Debug")
    var modelData: ModelData? = nil
    var timer: Timer? = nil

    private var socketStatus: Socket.Status {
        return Socket.default.status
    }

    deinit {
        stopTrackingStatus()
    }

    func trackStatus() {
        if timer != nil { return }

        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            if self.status != Socket.default.status {
                print("update remoteData.status to \(Socket.default.status)")
                self.status = Socket.default.status
            }
        }
    }

    func stopTrackingStatus() {
        timer?.invalidate()
        timer = nil
    }

    func enableDebug() -> RemoteData {
        debug = true

        return self
    }

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

        if socketStatus == .connecting {
            Socket.default.onConnect {
                callback?()
            }

            return
        }

        if socketStatus == .connected {
            callback?()

            return
        }

        Socket.default.connect { error in
            if error == nil {
                callback?()
            } else {
                self.error = error
            }
        }
    }

    func disconnect() {
        Socket.default.disconnect()
    }

    func onReconnect() {
        onReconnect(nil)
    }

    func onReconnect(_ callback: (() -> Void)?) {
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

            callback?()
        }
    }

    func ensureConnection(_ callback: @escaping () -> Void) {
        switch socketStatus {
            case .connected:
                callback()
            case .connecting:
                print("waiting for socket connection before action")
                Socket.default.onConnect {
                    self.onReconnect(callback)
                }
            case .notConnected:
                print("connecting socket before action")
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
        print("subscribe to items")

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
        if let indices = self.modelData?.getIndicesByStoreId(storeId) {
            let (categoryIndex, storeIndex) = indices
            self.modelData!.categories[categoryIndex].stores[storeIndex].items = items
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

    // TODO: add callback to this and tracking 'addingItem' state
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
                "item": item.serialize(),
            ])
        }
    }

    func moveItem(_ storeDetailModel: StoreDetailModel, _ from: IndexSet, _ to: Int) {
        modelData?.moveItem(storeDetailModel, from, to)

        if modelData == nil { return }

        Socket.default.emit("update:items", [
            "storeId": storeDetailModel.store.id,
            "items": modelData!.serializeItems(storeDetailModel),
        ])
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
