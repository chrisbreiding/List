import SwiftUI

struct Indicator: View {
    let status: Socket.Status

    var color: Color {
        switch status {
            case .notConnected:
                return Color.red
            case .connecting:
                return Color.yellow
            case .connected:
                return Color.green
        }
    }

    var body: some View {
        Image(systemName: "circle.fill")
            .foregroundColor(color)
            .font(.footnote)
    }
}

struct Indicator_Previews: PreviewProvider {
    static var previews: some View {
        Indicator(status: .connected)
    }
}
