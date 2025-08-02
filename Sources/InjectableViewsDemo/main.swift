import SwiftUI
import InjectableViews

@InjectableContainer
struct BaseFormView: View {
    var body: some View {
        VStack(spacing: 16) {
            emailField
            passwordField
        }
        .padding()
    }

    @InjectableView
    func emailFieldBuilder() -> some View {
        TextField("Email", text: .constant(""))
    }

    @InjectableView
    func passwordFieldBuilder() -> some View {
        SecureField("Password", text: .constant(""))
    }
}

struct CustomFormView: View {
    var body: some View {
        BaseFormView()
            .overrideView(for: .emailField) {
                TextField("Custom Email", text: .constant("override"))
                    .padding()
                    .background(Color.yellow.opacity(0.3))
            }
            .overrideView(for: .passwordField) {
                SecureField("Custom Password", text: .constant("override"))
                    .padding()
                    .background(Color.orange.opacity(0.3))
            }
    }
}

//@main
//struct DemoApp: App {
//    var body: some Scene {
//        WindowGroup {
//            CustomFormView()
//        }
//    }
//}

