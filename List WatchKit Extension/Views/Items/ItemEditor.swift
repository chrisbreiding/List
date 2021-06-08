//
//  ItemEditor.swift
//  List WatchKit Extension
//
//  Created by Chris Breiding on 6/5/21.
//

import SwiftUI

struct ItemEditor: View {
    @State var name: String
    let onSave: (String) -> Void
    let onCancel: () -> Void

    init(name: String, onSave: @escaping (String) -> Void, onCancel: @escaping () -> Void) {
        self.onSave = onSave
        self.onCancel = onCancel
        _name = State(initialValue: name)
    }

    let rgbValue = 40.0

    var body: some View {
        VStack(spacing: 5) {
            TextField("Item Name", text: $name)
            HStack {
                Button("Cancel", action: onCancel)
                .background(Color(red: rgbValue/255.0, green: rgbValue/255.0, blue: rgbValue/255.0))
                .foregroundColor(Color.red)
                .clipShape(Capsule())

                Button("Save", action: save)
                .background(Color.blue)
                .clipShape(Capsule())
            }
        }
        .navigationBarHidden(true)
    }

    func save() {
        onSave(name)
    }
}

struct ItemEditor_Previews: PreviewProvider {
    static var previews: some View {
        ItemEditor(
            name: "Bread",
            onSave: { name in },
            onCancel: {}
        )
    }
}
