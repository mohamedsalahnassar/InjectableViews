import SwiftUI
import InjectableViews

@InjectableContainer
struct BaseFormView: View {
    @InjectableView var emailField: some View
    @InjectableView var passwordField: some View

    var body: some View {
        VStack(spacing: 16) {
            emailField
            passwordField
        }
        .padding()
    }

    func emailFieldBuilder() -> some View {
        TextField("Email", text: .constant(""))
    }

    func passwordFieldBuilder() -> some View {
        SecureField("Password", text: .constant(""))
    }
}

struct CustomFormView: View {
    var body: some View {
        BaseFormView()
            .overrideView("emailField") {
                TextField("Custom Email", text: .constant("override"))
                    .padding()
                    .background(Color.yellow.opacity(0.3))
            }
            .overrideView("passwordField") {
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

