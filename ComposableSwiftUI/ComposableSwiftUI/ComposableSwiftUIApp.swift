//
//  ComposableSwiftUIApp.swift
//  ComposableSwiftUI
//
//  Created by Mohamed Nassar on 25/07/2025.
//

import SwiftUI

@main
struct ComposableSwiftUIApp: App {
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false

    var body: some Scene {
        WindowGroup {
            NavigationView {
                if isLoggedIn {
                    ProfileScreen()
                } else {
                    LoginScreen()
                }
            }
        }
    }
}
