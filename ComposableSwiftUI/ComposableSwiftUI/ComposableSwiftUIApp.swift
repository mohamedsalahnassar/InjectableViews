//
//  ComposableSwiftUIApp.swift
//  ComposableSwiftUI
//
//  Created by Mohamed Nassar on 25/07/2025.
//

import SwiftUI

@main
struct ComposableSwiftUIApp: App {
    var body: some Scene {
        WindowGroup {
            VStack {
                OriginalContentView()
                ModifiedContentView()
            }
        }
    }
}
