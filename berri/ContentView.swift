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
                }.tabItem { Label("Expenses", systemImage: "dollarsign.circle.fill").foregroundColor(.blue) }
                .tag(2)
                
                ZStack {
                }.tabItem { Label("Add", systemImage: "plus").foregroundColor(.blue) }
                .tag(3)
                
                ZStack {
                }.tabItem { Label {
                    Text("Settings")
                        .foregroundColor(Color.white)
                } icon: {
                    Image(systemName: "gear")
                        .foregroundColor(Color.white)
                } }
                .tag(4)
            }.accentColor(accent)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Image("berri").background(Color.init(red: 0.937, green: 0.824, blue: 0.827))
                }
            }
            .onAppear() {
                UITabBar.appearance().barTintColor = main
            }
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
