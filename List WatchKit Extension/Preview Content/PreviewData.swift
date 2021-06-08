//
//  PreviewData.swift
//  List WatchKit Extension
//
//  Created by Chris Breiding on 6/7/21.
//

import Foundation

struct PreviewData {
    static func get() -> [Category] {
        [
            Category(
                id: "c1",
                name: "Grocery",
                stores: [
                    Store(
                        id: "s1",
                        name: "Giant",
                        parentId: "p1",
                        items: [
                            Item(
                                id: "i1",
                                name: "Bread",
                                isChecked: false
                            ),
                            Item(
                                id: "i2",
                                name: "Milk",
                                isChecked: true
                            )

                        ]
                    ),
                    Store(
                        id: "s2",
                        name: "Trader Joe's",
                        parentId: "p1",
                        items: [
                            Item(
                                id: "i3",
                                name: "Cheese",
                                isChecked: false
                            ),
                            Item(
                                id: "i4",
                                name: "Bananas",
                                isChecked: false
                            )

                        ]
                    ),
                    Store(
                        id: "s3",
                        name: "Mom's",
                        parentId: "p1",
                        items: [
                            Item(
                                id: "i5",
                                name: "",
                                isChecked: false
                            )

                        ]
                    )
                ]
            )
        ]
    }
}
