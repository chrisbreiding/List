import SwiftUI

struct ItemRow: View {
    let item: Item
    let onUpdate: (Item) -> Void

    var body: some View {
        Button(action: {
            var clone = item
            clone.isChecked = !item.isChecked
            onUpdate(clone)
        }) {
            HStack(spacing: 10) {
                Image(systemName: item.isChecked ? "checkmark.square" : "square")
                Text(item.name)
                    .foregroundColor(item.isChecked ? Color.gray : Color.white)
                    .strikethrough(item.isChecked)
                Spacer()
            }
            .padding(.top, 10)
            .padding(.bottom, 10)
        }
    }
}

struct ItemRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            ItemRow(
                item: Item(
                    id: "1",
                    name: "Bananas",
                    isChecked: false
                ),
                onUpdate: { item in }
            )
            ItemRow(
                item: Item(
                    id: "1",
                    name: "Some food that requires multiple lines",
                    isChecked: false
                ),
                onUpdate: { item in }
            )
        }
    }
}
