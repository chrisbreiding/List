import SwiftUI

struct ErrorView: View {
    @State private var showStack = false
    let error: Error
    let onRetry: (() -> Void)?

    init(error: Error, onRetry: (() -> Void)? = nil) {
        self.error = error
        self.onRetry = onRetry
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 5) {
                Text("An Error Occurred:")
                Text(error.message)
                Button(action: { showStack = !showStack }) {
                    Image(systemName: showStack ? "chevron.down" : "chevron.right")
                    Text(showStack ? "Hide Stack" : "Show Stack")
                }
                .foregroundColor(Color.gray)
                if showStack {
                    Text(error.stack)
                }
                if onRetry != nil {
                    Button(action: onRetry!) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                        Text("Try Again")
                    }
                    .foregroundColor(Color.blue)
                }
            }
            .foregroundColor(Color.red)
        }
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView(error: Error(
            name: "Error",
            message: "There was an oopsie daisy",
            stack: "There was an oopsie daisy\n  at <func> (foo/bar/baz.js:1:21)\n  at <funky> (foo/bar/baz.js:5:7)",
            reason: .connection
        ))
    }
}
