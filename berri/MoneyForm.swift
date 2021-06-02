//
//  MoneyForm.swift
//  berri
//
//  Created by Isabella Heppe on 6/1/21.
//

import Foundation
import SwiftUI
import SwiftUIKit


struct AddMoney: View {
    @State var accounts : [String]
    @State var categories: [String]
    @State var selector = 1
    var body: some View {
        GeometryReader { m in
            NavigationView {
                VStack {
                    Text("Choose a transaction type: ")
                    Picker(selection: $selector, label: Text("Types"), content: {
                        Text("Expense").tag(1)
                        Text("Income").tag(2)
                        Text("Transfer").tag(3)
                    })
                    NavigationLink(
                        destination: ConfirmAccount(moneyType: $selector, width: m.size.width, height: m.size.height, accounts: accounts, categories: categories),
                        label: {
                            Text("Next")
                        })
                }
            }
        }
    }
}

struct ConfirmAccount: View {
    @Binding var moneyType: Int
    @State var width: CGFloat
    @State var height: CGFloat
    @State var value : Double? = 0.0
    var accounts: [String]
    var categories: [String]
    @State var expIn = Transaction
    @State var expOut = Transaction
    @State var category = String
    var body: some View {
        Text("The transaction category:")
        Picker(category, selection: $category) {
            category == "" ? Text(category) : nil
            ForEach(categories, id: \.self) {
                Text($0)
            }
        }.frame(width: width/2, height: height/9).pickerStyle(MenuPickerStyle())
        Spacer()
        if (moneyType != 2) {
            Text("Account to pull from:")
            Picker(expIn.account, selection: $expIn.account) {
                expIn.account == "" ? Text(expIn.account) : nil
                ForEach(accounts, id: \.self) {
                    Text($0)
                }
            }.frame(width: width/2, height: height/9).pickerStyle(MenuPickerStyle())
        }
        if (moneyType == 3) {
            Spacer()
        }
        if (moneyType != 1) {
            Text("Account to add to:")
            Picker(expOut.account, selection: $expOut.account) {
                expOut.account == "" ? Text(expOut.account) : nil
                ForEach(accounts, id: \.self) {
                    Text($0)
                }
            }.frame(width: width/2, height: height/9).pickerStyle(MenuPickerStyle())
        }
        Spacer()
        Text("Amount of money:")
        CurrencyTextField("Amount", value: self.$value, alwaysShowFractions: false, numberOfDecimalPlaces: 2, currencySymbol: "US$")
                    .font(.largeTitle)
                    .multilineTextAlignment(TextAlignment.center)
        Spacer()
        Button(action:{
            print(value)
        }, label: {
            Text("Confirm")
        })
    }
}
