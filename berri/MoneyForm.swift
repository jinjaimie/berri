//
//  MoneyForm.swift
//  berri
//
//  Created by Isabella Heppe on 6/1/21.
//

import Foundation
import SwiftUI
import SwiftUIKit
import Firebase

struct ConfirmAccount: View {
    @State var moneyType: [String] = ["Expense", "Income", "Transfer"]
    @State var selector = "Expense"
    @State var width: CGFloat
    @State var height: CGFloat
    @State var value : Double? = 0.0
    @State var accounts: [String]
    @State var categories: [String]
    @State var incomes: [String]
    @ObservedObject private var addItem = NewTransaction()
    
    @State var category : String = ""
    
    var body: some View {
        VStack() {
                Picker("Type", selection: $selector) {
                    ForEach(moneyType, id: \.self) {
                        Text($0)
                    }
                }.pickerStyle(SegmentedPickerStyle()).frame(width: width / 1.5)
            ScrollView() {
                VStack(spacing: 15){
                    Spacer()
                    if (selector == "Transfer") {
                        Text("Transfer from " + addItem.accountOut + " to " + addItem.accountIn).fontWeight(.bold).foregroundColor(.black)
                        Spacer()
                        HStack {
                            Picker(selection: $addItem.accountIn, label: HStack {
                                Text("Account to add to:").fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/).foregroundColor(Color("AccentColor"))
                                Spacer()
                                addItem.accountIn == "" ? Text("Select") : Text(addItem.accountIn)
                            }) {
                                ForEach(accounts, id: \.self) {
                                    Text($0)
                                }
                            }.pickerStyle(MenuPickerStyle())
                        }.frame(width: width / 1.2)
                        Spacer()
                    }
                    if (selector != "Transfer") {
                        Spacer()
                        HStack(spacing: 10) {
                            Text("Name of Transaction").fontWeight(.bold).foregroundColor(Color("AccentColor"))
                            TextField(addItem.name, text: $addItem.name).font(.title).border(Color.black).padding(10)
                        }.frame(width: width/1.2)
                        Spacer()
                        HStack {
                          
                            VStack {
                                Picker(selection: $addItem.category, label: HStack {
                                    Text("Category of Transaction:").fontWeight(.bold).foregroundColor(Color("AccentColor"))
                                    Spacer()
                                    addItem.category == "" ? Text("Select") : Text(addItem.category)
                                }) {
                                    ForEach(categories, id: \.self) {
                                        Text($0)
                                    }
                                }.pickerStyle(MenuPickerStyle()).id(self.addItem.category)
                            }
                        }.frame(width: width / 1.2)
                        Spacer()
                    }
                    
                    if (selector != "Income") {
                        Spacer()
                        HStack {
                            Picker(selection: $addItem.accountOut, label: HStack {
                                Text("Account to pull from:").fontWeight(.bold).foregroundColor(Color("AccentColor"))
                                Spacer()
                                addItem.accountOut == "" ? Text("Select") : Text(addItem.accountOut)
                            }) {
                                
                                ForEach(accounts, id: \.self) {
                                    Text($0)
                                }
                            }.pickerStyle(MenuPickerStyle())
                        }.frame(width: width / 1.2)
                        Spacer()
                    }
                    
                    if (selector == "Income") {
                        Spacer()
                        HStack {
                            Picker(selection: $addItem.incomeType, label: HStack {
                                Text("Income Type: ").fontWeight(.bold).foregroundColor(Color("AccentColor"))
                                Spacer()
                                addItem.incomeType == "" ? Text("Select") : Text(addItem.incomeType)
                            }) {
                                ForEach(incomes, id: \.self) {
                                    Text($0)
                                }
                            }.pickerStyle(MenuPickerStyle())
                        }.frame(width: width / 1.2)
                        Spacer()
                        HStack {
                            Picker(selection: $addItem.accountIn, label: HStack {
                                Text("Account to add to: ").fontWeight(.bold).foregroundColor(Color("AccentColor"))
                                Spacer()
                                addItem.accountIn == "" ? Text("Select") : Text(addItem.accountIn)
                            }) {
                                ForEach(accounts, id: \.self) {
                                    Text($0)
                                }
                            }.pickerStyle(MenuPickerStyle())
                        }.frame(width: width / 1.2)
                        Spacer()
                    }
                    HStack {
                        Text("Date of Transaction: ").fontWeight(.bold).foregroundColor(Color("AccentColor")).multilineTextAlignment(/*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/)
                        Spacer()
                        DatePicker(selection: $addItem.convDate, displayedComponents: [.date]) {
                        }
                    }.frame(width: width/1.2)
                    Spacer()
                    HStack {
                    Text("Amount of money:").fontWeight(.bold).foregroundColor(Color("AccentColor"))
                    
                        CurrencyTextField("Amount", value: self.$value, alwaysShowFractions: false, numberOfDecimalPlaces: 2, currencySymbol: "US$").font(.title).multilineTextAlignment(TextAlignment.trailing)
                    
                    }.frame(width: width/1.2)
                    Spacer()
                }
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        self.addItem.name = ""
                        self.addItem.value = 0.0
                        self.addItem.accountIn = ""
                        self.addItem.accountOut = ""
                        self.addItem.date = ""
                        self.addItem.incomeType = ""
                        self.addItem.category = ""
                    }) {
                        Text("Clear").fontWeight(.bold).foregroundColor(.black).font(.title2)
                    }
                    Spacer()
                    Button(action: {
                        let ref = Database.database().reference().child(Auth.auth().currentUser!.uid)
                        let tempConvDate = showItems.itemDateFormat.string(from: addItem.convDate)
                                            
                        if (selector == "Expense") {
                       
                            let newKey : String = ref.child("expenditure").childByAutoId().key!
                            ref.child("expenditures").child(newKey).setValue(["account": addItem.accountOut, "category": addItem.category, "date": tempConvDate, "name": addItem.name, "value": -abs(self.value!)])
                            print("did expense at ", newKey)
                          
                        } else if (selector == "Income") {
                         
                            let newKey : String = ref.child("income").childByAutoId().key!
                            ref.child("income").child(newKey).setValue(["account": addItem.accountIn, "category": addItem.category, "date": tempConvDate, "incomeType": addItem.incomeType, "name": addItem.name, "value": abs(self.value!)])
                            print("did income at: ", newKey)
                     
                        } else if (selector == "Transfer") {
                        
                            addItem.name = (addItem.accountOut + " to " + addItem.accountIn)
                            let newKeyI : String = ref.child("income").childByAutoId().key!
                            ref.child("income").child(newKeyI).setValue(["account": addItem.accountIn, "category": "", "date": tempConvDate, "incomeType": "Transfer", "name": (addItem.accountOut + " to " + addItem.accountIn), "value": -abs(self.value!)])
                            let newKeyE : String = ref.child("expenditure").childByAutoId().key!
                            ref.child("expenditures").child(newKeyE).setValue(["account": addItem.accountOut, "category": "Transfer", "date": tempConvDate, "name": addItem.name, "value": abs(self.value!)])
                        }
                    }) {
                        Text("Submit").font(.title2).fontWeight(.bold).foregroundColor(.black)
                    }
                    Spacer()
                }
            }
        }
    }
}

