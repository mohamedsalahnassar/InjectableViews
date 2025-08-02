//
//  ProfileScreen.swift
//  ComposableSwiftUI
//
//  Created by mohammednassar on 28/07/2025.
//


import SwiftUI
import InjectableViews

@InjectableContainer
struct ProfileScreen: View {
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        VStack(spacing: 24) {
            avatar

            menu

            logoutButton
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
                .shadow(radius: 5)
        )
        .padding()
        .navigationTitle("Profile")
    }

    @InjectableView
    @ViewBuilder private func avatarBuilder() -> some View {
        Image(systemName: "person.circle.fill")
            .resizable()
            .frame(width: 150, height: 150)
            .foregroundColor(.blue)
            .padding()
    }

    @InjectableView
    @ViewBuilder private func menuBuilder() -> some View {
        NavigationLink("Address Update", destination: AddressUpdateScreen())
            .buttonStyle(.bordered)
            .padding()
    }

    @InjectableView
    @ViewBuilder private func logoutButtonBuilder() -> some View {
        Button(action: {
            isLoggedIn = false
            presentationMode.wrappedValue.dismiss()
        }) {
            Text("Logout")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red)
                .cornerRadius(8)
        }
        .padding(.horizontal)
    }
}
