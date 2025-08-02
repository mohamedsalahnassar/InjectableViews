//
//  OverriddenAddressUpdateScreen.swift
//  ComposableSwiftUI
//
//  Created by mohammednassar on 28/07/2025.
//


import SwiftUI
import InjectableViews

struct OverriddenAddressUpdateScreen: View {
    @State private var selectedCountry: String = "USA"
    @State private var selectedCity: String = "New York"

    var body: some View {
        AddressUpdateScreen()
            .overrideView(for: .countryField) {
                Picker("Country", selection: $selectedCountry) {
                    Text("USA").tag("USA")
                    Text("Canada").tag("Canada")
                    Text("UK").tag("UK")
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                .background(Color.purple.opacity(0.1))
                .cornerRadius(8)
            }
            .overrideView(for: .cityField) {
                Picker("City", selection: $selectedCity) {
                    Text("New York").tag("New York")
                    Text("Toronto").tag("Toronto")
                    Text("London").tag("London")
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                .background(Color.purple.opacity(0.1))
                .cornerRadius(8)
            }
            .overrideView(for: .showNewScreenButton) {
                EmptyView()
            }
    }
}
