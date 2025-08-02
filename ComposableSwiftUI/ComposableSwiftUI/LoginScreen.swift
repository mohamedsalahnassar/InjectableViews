//
//  LoginScreen.swift
//  ComposableSwiftUI
//
//  Created by mohammednassar on 28/07/2025.
//


import SwiftUI
import InjectableViews

@InjectableContainer
struct LoginScreen: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        VStack(spacing: 24) {
            Text("Welcome Back!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.blue)

            usernameField
            passwordField

            loginButton
        }
        .padding()
        .background(
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.white]), startPoint: .top, endPoint: .bottom)
                .cornerRadius(16)
                .shadow(radius: 5)
        )
        .padding()
        .navigationTitle("Login")
    }

    @InjectableView
    @ViewBuilder private var usernameFieldBuilder: some View {
        TextField("Username", text: $username)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)
    }

    @InjectableView
    @ViewBuilder private func passwordFieldBuilder() -> some View {
        SecureField("Password", text: $password)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)
    }

    @InjectableView
    @ViewBuilder private func loginButtonBuilder() -> some View {
        Button(action: {
            isLoggedIn = true
            presentationMode.wrappedValue.dismiss()
        }) {
            Text("Login")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
                .cornerRadius(8)
        }
        .padding(.horizontal)
    }
}
