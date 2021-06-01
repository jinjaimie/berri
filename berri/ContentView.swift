//
//  ContentView.swift
//  berri
//
//  Created by Saatvik Arya on 5/26/21.
//

import SwiftUI

struct ContentView: View {
    let main:UIColor = UIColor(red: 0.937, green: 0.824, blue: 0.827, alpha: 1)
    let accent:Color = Color(red: 0.64, green: 0.36, blue: 0.25)

    var body: some View {
        NavigationView {
            TabView {
                ZStack {
                }.tabItem { Label("Account", systemImage: "person.fill") }
                .tag(1)
                
                ZStack {
                }.tabItem { Label("Expenses", systemImage: "dollarsign.circle.fill").foregroundColor(.white) }
                .tag(2)
                
                ZStack {
                }.tabItem { Label("Add", systemImage: "plus").foregroundColor(.white) }
                .tag(3)
                
                ZStack {
                    SettingView().tag(1)
                }.tabItem { Label("Settings", systemImage: "gear") }
                .tag(4)
            }.accentColor(accent)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Image("berri")
                }
            }
            .onAppear() {
                UITabBar.appearance().barTintColor = main
            }
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct SettingView: View {
    var body: some View {
        VStack (spacing: 5) {
            NavigationLink(
                destination: AccountForm()) {
                    Text("Add an account").padding()
            }
            NavigationLink(
                destination: CategoryForm()) {
                Text("Add a category").padding()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
