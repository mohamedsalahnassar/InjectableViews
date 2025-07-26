import SwiftUI
import InjectableViews

//struct BaseFormView: View {
//    @InjectableView var emailField: AnyView = AnyView(TextField("Email", text: .constant("")))
//    @InjectableView var passwordField: AnyView = AnyView(SecureField("Password", text: .constant("")))
//
//    var body: some View {
//        VStack(spacing: 16) {
//            emailField
//            passwordField
//        }
//        .padding()
//    }
//}
//
//struct CustomFormView: View {
//    var body: some View {
//        InjectableProvider {
//            BaseFormView()
//                .overrideView("emailField") {
//                    TextField("Custom Email", text: .constant("override"))
//                        .padding()
//                        .background(Color.yellow.opacity(0.3))
//                }
//                .overrideView("passwordField") {
//                    SecureField("Custom Password", text: .constant("override"))
//                        .padding()
//                        .background(Color.orange.opacity(0.3))
//                }
//        }
//    }
//}

//@main
//struct DemoApp: App {
//    var body: some Scene {
//        WindowGroup {
//            CustomFormView()
//        }
//    }
//}
