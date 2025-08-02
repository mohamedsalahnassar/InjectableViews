//
//  OverriddenLoginScreen.swift
//  ComposableSwiftUI
//
//  Created by mohammednassar on 28/07/2025.
//

import SwiftUI
import InjectableViews

struct OverriddenLoginScreen: View {
    @State private var password: String = ""
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false

    var body: some View {
        LoginScreen()
            .overrideView(for: .usernameField) {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.purple)
                    .padding()
                    .background(Circle().fill(Color.purple.opacity(0.2)))
            }
            .overrideView(for: .passwordField) {
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(8)
            }
    }
}
