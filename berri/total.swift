//
//import Foundation
//import SwiftUI
//import Firebase
//
//struct TotalExpenseViews: View {
//    @State var tempAccounts = [String]()
//    @State var tempCategories = [String]()
//    @State var expenseList = [Expense]()
//    @State var reconList = [Expense]()
//    @State var incomeList = [Income]()
//    @State var timeFilter = "MONTH"
//    @State var text = "Hello World"
//    let times = ["DAY", "WEEK", "MONTH", "YEAR"]
//    
//    var body: some View {
//        GeometryReader { m in
//            NavigationView {
//                Expenditures(tempAccounts: tempAccounts, tempCategories: tempCategories, expenseList: expenseList, expenses: expenseList, reconList: reconList)
//                                .navigationBarItems(leading: {
//                                    Menu {
//                                        Button(action: {
//                                            self.expenseList = self.expenses
//                                            self.curView = "Expenses"
//                                        }) {
//                                            Text("Expenses")
//                                        }
//                                        Button(action: {
//                                            self.expenseList = self.reconList
//                                            self.curView = "Recon"
//                                        }) {
//                                            Text("Recon")
//                                        }
//                                        Button(action: {
//                                            self.expenseList = self.incomeList
//                                            self.curView = "Income"
//                                        }) {
//                                            Text("Income")
//                                        }} label: {
//                                        Text("Test")
//                                    }.navigationBarTitleDisplayMode(.inline)
//                                    
//                                }())
//                        }
//                        .navigationViewStyle(StackNavigationViewStyle())
//            
//        }
//    }
//}
