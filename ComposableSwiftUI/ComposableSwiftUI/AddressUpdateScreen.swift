//
//  AddressUpdateScreen.swift
//  ComposableSwiftUI
//
//  Created by mohammednassar on 28/07/2025.
//


import SwiftUI
import InjectableViews

@InjectableContainer
struct AddressUpdateScreen: View {
    @State private var country: String = ""
    @State private var city: String = ""

    var body: some View {
        VStack(spacing: 24) {
            Text("Update Address")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.green)

            countryField
            cityField

            updateButton
            showNewScreenButton
        }
        .padding()
        .background(
            LinearGradient(gradient: Gradient(colors: [Color.green.opacity(0.2), Color.white]), startPoint: .top, endPoint: .bottom)
                .cornerRadius(16)
                .shadow(radius: 5)
        )
        .padding()
        .navigationTitle("Address Update")
    }

    @InjectableView
    @ViewBuilder private func countryFieldBuilder() -> some View {
        TextField("Country", text: $country)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
            .background(Color.green.opacity(0.1))
            .cornerRadius(8)
    }

    @InjectableView
    @ViewBuilder private func cityFieldBuilder() -> some View {
        TextField("City", text: $city)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
            .background(Color.green.opacity(0.1))
            .cornerRadius(8)
    }

    @InjectableView
    @ViewBuilder private func updateButtonBuilder() -> some View {
        NavigationLink(destination: OverriddenAddressUpdateScreen()) {
            Text("Update")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(LinearGradient(gradient: Gradient(colors: [Color.green, Color.blue]), startPoint: .leading, endPoint: .trailing))
                .cornerRadius(8)
        }
        .padding(.horizontal)
    }

    @InjectableView
    @ViewBuilder private func showNewScreenButtonBuilder() -> some View {
        NavigationLink(destination: OverriddenAddressUpdateScreen()) {
            Text("Show New Screen")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.orange)
                .cornerRadius(8)
        }
        .padding(.horizontal)
    }
}
