//
//  ContentView.swift
//  ComposableSwiftUI
//
//  Created by Mohamed Nassar on 25/07/2025.
//

import SwiftUI
import InjectableViews

@InjectableContainer
struct OriginalContentView: View {
    @State private var emailFieldValue: String = ""
    @State private var passwordFieldValue: String = ""

    var body: some View {
        VStack(spacing: 16) {
            emailField
            passwordField
            Text(emailFieldValue)
            Text(passwordFieldValue)
        }
        .padding()
    }

    @InjectableView
    @ViewBuilder private func emailFieldBuilder() -> some View {
        TextField("Email", text: $emailFieldValue)
    }

    @InjectableView
    @ViewBuilder private func passwordFieldBuilder() -> some View {
        SecureField("Password", text: $passwordFieldValue)
    }
}

struct ModifiedContentView: View {
    @State private var confirmPasswordFieldValue: String = ""
    var body: some View {
        OriginalContentView()
            .overrideView(for: .passwordField) {
                VStack {
                    SecureField("New Password", text: .constant(""))
                        .padding()
                        .background(Color.orange.opacity(0.3))
                    SecureField("Confirm Password", text: $confirmPasswordFieldValue)
                        .padding()
                        .background(Color.orange.opacity(0.3))
                    Text(confirmPasswordFieldValue)
                }
            }
//            .overrideView(for: .passwordField) {
//                VStack {
//                    SecureField("New Password", text: .constant(""))
//                        .padding()
//                        .background(Color.orange.opacity(0.3))
//                    SecureField("Confirm Password", text: $confirmPasswordFieldValue)
//                        .padding()
//                        .background(Color.orange.opacity(0.3))
//                    Text(confirmPasswordFieldValue)
//                }
//            }
    }
}

#Preview {
    VStack {
        Text("Original View")
        OriginalContentView()
            .padding()
            .overlay {
                RoundedRectangle(cornerRadius: 10, style: .circular)
                    .strokeBorder(lineWidth: 2, antialiased: true)
            }
            .padding()

        Text("Overridden View")
        ModifiedContentView()
            .padding()
            .overlay {
                RoundedRectangle(cornerRadius: 10, style: .circular)
                    .strokeBorder(lineWidth: 2, antialiased: true)
            }
            .padding()
    }
}
