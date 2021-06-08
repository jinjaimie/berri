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
    @Binding var accounts: [String]
    @Binding var categories: [String]
    @Binding var incomes: [String]
    @ObservedObject private var addItem = NewTransaction()
    
    @State var category : String = ""
    
    var body: some View {
        VStack(spacing: 10) {
                Picker("Type", selection: $selector) {
                    ForEach(moneyType, id: \.self) {
                        Text($0)
                    }
                }.pickerStyle(SegmentedPickerStyle()).frame(width: width / 1.5)
            ScrollView() {
                Spacer()
                if (selector == "Transfer") {
                    Text("Transfer from " + addItem.accountOut + " to " + addItem.accountIn)
                    HStack {
                        Picker(selection: $addItem.accountIn, label: HStack {
                            Text("Account to add to:")
                            Spacer()
                            addItem.accountIn == "" ? Text("Select") : Text(addItem.accountIn)
                        }) {
                            ForEach(accounts, id: \.self) {
                                Text($0)
                            }
                        }.pickerStyle(MenuPickerStyle())
                    }.frame(width: width / 1.2)
                }
                if (selector != "Transfer") {
                    HStack(spacing: 10) {
                        Text("Name of Transaction").fontWeight(.bold)
                        TextField(addItem.name, text: $addItem.name).font(.title).border(Color.black).padding(10)
                    }.frame(width: width/1.2)
                    
                    HStack {
                      
                        VStack {
                            Picker(selection: $addItem.category, label: HStack {
                                Text("Category of Transaction:")
                                Spacer()
                                addItem.category == "" ? Text("Select") : Text(addItem.category)
                            }) {
                                ForEach(categories, id: \.self) {
                                    Text($0)
                                }
                            }.pickerStyle(MenuPickerStyle()).id(self.addItem.category)
                        }
                    }.frame(width: width / 1.2)
                }
                Spacer()
                
                if (selector != "Income") {
                    HStack {
                        Picker(selection: $addItem.accountOut, label: HStack {
                            Text("Account to pull from:")
                            Spacer()
                            addItem.accountOut == "" ? Text("Select") : Text(addItem.accountOut)
                        }) {
                            
                            ForEach(accounts, id: \.self) {
                                Text($0)
                            }
                        }.pickerStyle(MenuPickerStyle())
                    }.frame(width: width / 1.2)
                }
                Spacer()
                
                if (selector == "Income") {
                    HStack {
                        Picker(selection: $addItem.incomeType, label: HStack {
                            Text("Income Type: ")
                            Spacer()
                            addItem.incomeType == "" ? Text("Select") : Text(addItem.incomeType)
                        }) {
                            ForEach(incomes, id: \.self) {
                                Text($0)
                            }
                        }.pickerStyle(MenuPickerStyle())
                    }.frame(width: width / 1.2)
                    HStack {
                        Picker(selection: $addItem.accountIn, label: HStack {
                            Text("Account to add to: ")
                            Spacer()
                            addItem.accountIn == "" ? Text("Select") : Text(addItem.accountIn)
                        }) {
                            ForEach(accounts, id: \.self) {
                                Text($0)
                            }
                        }.pickerStyle(MenuPickerStyle())
                    }.frame(width: width / 1.2)
                }
                
              
                HStack {
                    Text("Date of Transaction: ").fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/).multilineTextAlignment(/*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/)
                    Spacer()
                    DatePicker(selection: $addItem.convDate, displayedComponents: [.date]) {
                    }
                }.frame(width: width/1.2)
                HStack {
                Text("Amount of money:")
                
                    CurrencyTextField("Amount", value: self.$value, alwaysShowFractions: false, numberOfDecimalPlaces: 2, currencySymbol: "US$").font(.largeTitle).multilineTextAlignment(TextAlignment.center)
                
                }.frame(width: width/1.2)
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
                   Text("Clear").font(.title2)
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
                    Text("Submit").font(.title2)
                }
                Spacer()
            }
            Spacer()
            
        }
    }
}

