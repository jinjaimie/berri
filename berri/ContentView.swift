//
//  ContentView.swift
//  berri
//
//  Created by Saatvik Arya on 5/26/21.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Text("Hello, world!")
            .padding()
    }
}

struct AddMoney: View {
    @State var selector = 1
    var body: some View {
        NavigationView {
            VStack {
                Text("Choose category: ")
                Picker(selection: $selector, label: Text("Category"), content: {
                    Text("Expense").tag(1)
                    Text("Income").tag(2)
                    Text("Transfer").tag(3)
                })
                NavigationLink(
                    destination: ConfirmAccount(),
                    label: {
                        Text("Next")
                    })
            }
        }
    }
}

struct ConfirmAccount: View {
    var body: some View {
        Text("Money")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
