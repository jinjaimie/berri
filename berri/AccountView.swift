//
//  AccountView.swift
//  berri
//
//  Created by Saatvik Arya on 6/1/21.
//

import SwiftUI

struct AccountView: View {
    @ObservedObject var handler: FirebaseHandler
    
    var body: some View {
        GeometryReader { m in
            NavigationView {
                VStack(spacing: 5) {
                    Text("Wallet").bold()
                    Spacer()
                    ScrollView {
                        ForEach (Array(handler.tempAccounts.keys), id: \.self) { (account) in
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 5).fill(Color.init(red: 0.66, green: 0.66, blue: 0.66)).frame(width: m.size.width / 1.2, height: m.size.height / 9, alignment: .center)
                                VStack(alignment: .center) {
                                    Spacer()
                                    Text(account).foregroundColor(.black)
                                    Text("$" + String(handler.tempAccounts[account] ?? 0.0)).bold().foregroundColor(.black)
                                    Spacer()
                                }
                            }
                            
                        }
                    }.frame(height: m.size.height, alignment: .topLeading)
                    
                    
                }
            }
        }.navigationViewStyle(StackNavigationViewStyle())
            
    }
}
