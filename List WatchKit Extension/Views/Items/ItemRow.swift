import SwiftUI

struct ItemRow: View {
    @State private var isEditing = false
    let item: Item
    let onUpdate: (Item) -> Void

    var body: some View {
        HStack {
            Image(systemName: item.isChecked ? "checkmark.square" : "square")
            .frame(width: 30, height: 30, alignment: .center)
            .padding(.top, 5)
            .padding(.bottom, 5)
            .onTapGesture(perform: toggleChecked)

            // all the frame and contentShape stuff is to make
            // the entire area to the right of the checkbox tappable
            // and not just the text itself
            HStack {
                Text(item.name == "" ? " " : item.name)
                .foregroundColor(item.isChecked ? Color.gray : Color.white)
                .strikethrough(item.isChecked)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            }
            .contentShape(Rectangle())
            .padding(.top, 10)
            .padding(.bottom, 10)
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            .onTapGesture(perform: {
                print("edit name")
                isEditing.toggle()
            })
            .sheet(isPresented: $isEditing) {
                ItemEditor(
                    name: item.name,
                    onSave: updateName,
                    onCancel: cancelEdit
                )
            }
        }
    }

    func toggleChecked() {
        print("toggle checked to: \(!item.isChecked)")

        var clone = item
        clone.isChecked = !item.isChecked
        onUpdate(clone)
    }

    func updateName(name: String) {
        isEditing = false

        if item.name != name {
            print("update name to: \(name)")

            var clone = item
            clone.name = name
            onUpdate(clone)
        }
    }

    func cancelEdit() {
        isEditing = false
    }
}

struct ItemRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            ItemRow(
                item: Item(
                    id: "1",
                    name: "Bananas",
                    isChecked: true
                ),
                onUpdate: { item in }
            )
            ItemRow(
                item: Item(
                    id: "2",
                    name: "",
                    isChecked: false
                ),
                onUpdate: { item in }
            )
            ItemRow(
                item: Item(
                    id: "3",
                    name: "Some food that requires multiple lines",
                    isChecked: false
                ),
                onUpdate: { item in }
            )
        }
    }
}
