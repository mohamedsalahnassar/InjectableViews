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
    @InjectableView private var emailField: some View
    @InjectableView private var passwordField: some View

    var body: some View {
        VStack(spacing: 16) {
            emailField
            passwordField
            Text(emailFieldValue)
            Text(passwordFieldValue)
        }
        .padding()
    }

    @ViewBuilder
    private func emailFieldBuilder() -> some View {
        TextField("Email", text: $emailFieldValue)
    }

    @ViewBuilder
    private func passwordFieldBuilder() -> some View {
        SecureField("Password", text: $passwordFieldValue)
    }
}

struct ModifiedContentView: View {
    @State private var confirmPasswordFieldValue: String = ""
    var body: some View {
        OriginalContentView()
            .overrideView("passwordField") {
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
