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
            //NavigationView {
            HStack {
                Spacer()
                VStack(spacing: 5) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 5).fill(Color.init(red: 0.66, green: 0.66, blue: 0.99)).frame(width: m.size.width / 1.2, height: (m.size.height / CGFloat(10)) * 2, alignment: .center)
                        VStack {
                            Text("Total Assets").font(.title3).foregroundColor(.black).textCase(.uppercase)
                            Text("$" + String(format:  "%.2f",  (handler.expenseList + handler.incomeList).map({$0.value}).reduce(handler.tempAccounts.map({$0.value}).reduce(0,+), +))).foregroundColor(.black).font(.largeTitle).fontWeight(.heavy)
                        }
                    }
                    ScrollView {
                        ForEach (Array(handler.tempAccounts.keys.sorted(by: {$0 < $1})), id: \.self) { (account) in
                            let expenses = handler.reconList.filter({$0.account == account}) + handler.incomeList.filter({$0.account == account})
                            NavigationLink(destination: ExpenseListByCategory(category: account, expenses: expenses, width: m.size.width, height: m.size.height, tempAccounts: handler.tempAccount, tempCategories: handler.tempCategories, tempIncome: handler.tempIncome, fbHandler: handler)) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 5).fill(Color.init(red: 0.66, green: 0.66, blue: 0.66)).frame(width: m.size.width / 1.2, height: m.size.height / 9, alignment: .center)
                                VStack(alignment: .center) {
                                    Spacer()
                                    Text(account).foregroundColor(.black)
                                    Text("$" + String(format:  "%.2f",  expenses.map({$0.value}).reduce(handler.tempAccounts[account]!, +))).bold().foregroundColor(.black)
                                    Spacer()
                                }
                            }
                            }
                        }
                    }.frame(height: m.size.height, alignment: .topLeading)
             
                }
                Spacer()
            }
        }.navigationViewStyle(StackNavigationViewStyle())
            
    }
}
