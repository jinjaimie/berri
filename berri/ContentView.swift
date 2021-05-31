//
//  ContentView.swift
//  berri
//
//  Created by Saatvik Arya on 5/26/21.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Text("Hello, world!")
                .padding().tabItem {
                    Image(systemName: "hand.thumbsup.fill")
                    Text("Home")
                }.tag(1)
            
            Expenditures().tabItem {
                Image(systemName: "hand.thumbsup.fill")
                Text("Good")
            }.tag(2)
            
        }
        
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
        Expenditures()
        //        ExpenseListByCategory(category: "Rent/Utilities", expenses: [Expense(account: "Checking", category: "Rent/Utilities", date: "05/14/2015", name: "Hannah Rent Payback June", value: 960.99)
        ////                                                                     Expense(account: "Checking", category: "Rent/Utilities", date: "05/14/2015", name: "Jan Rent Payback June", value: 960.99)
        //        ], width: CGFloat(390), height: CGFloat(763))
    }
}


//
//  expenditures.swift
//  berri
//
//  Created by stlp on 5/29/21.
//

import Foundation
import SwiftUI
import Firebase

struct Expenditures: View {
    @State var tempAccounts = [String]()
    @State var tempCategories = [String]()
    @State var expenseList = [Expense]()
    
    
    let times = ["Daily", "Weekly", "Monthly", "Yearly"]
    var body: some View {
        GeometryReader { m in
            NavigationView {
                VStack(spacing: 10) {
                    HStack {
                        ForEach (times, id: \.self) { t in
                            Text(t).font(.title3).textCase(.uppercase)
                        }
                    }
                    VStack(spacing: 5) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 5).fill(Color.init(red: 0.99, green: 0.66, blue: 0.66)).frame(width: m.size.width / 1.2, height: (m.size.height / CGFloat(10)) * 2, alignment: .center)
                            VStack {
                                Text("Spent").font(.title3).foregroundColor(.black).textCase(.uppercase)
                                Text("$" + String(self.totalPrice())).foregroundColor(.black).font(.largeTitle).fontWeight(.heavy)
                            }
                        }
                        ScrollView(.vertical) {
                            ForEach (tempCategories, id: \.self) { c in
                                VStack {
                                    HStack {
                                        NavigationLink(destination: ExpenseListByCategory(category: c, expenses:  expenseList.filter({ $0.category == c }), width: m.size.width, height: m.size.height, num: expenseList.count + 1)) {
                                            Spacer()
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 5).fill(Color.init(red: 0.66, green: 0.66, blue: 0.66)).frame(width: m.size.width / 1.2, height: m.size.height / 9, alignment: .center)
                                                HStack {
                                                    Text(c).foregroundColor(.black).textCase(.uppercase)
                                                    Spacer()
                                                    HStack {
                                                        Text("$" + String(self.curTotal(cat: c))).foregroundColor(.black).fontWeight(.medium)
                                                        Image(systemName: "chevron.right")
                                                    }
                                                }.frame(width: m.size.width / 1.4, height: m.size.height / 9, alignment: .center)
                                            }
                                            Spacer()
                                        }
                                        //                                    Categories(category: c, num: flatten().count, width: m.size.width, height: m.size.height, exp: self.flatten())
                                    }
                                }
                            }.navigationBarHidden(true).frame(height: m.size.height, alignment: .topLeading)
                        }.onAppear(perform: loadData)
                    }
                    
                }
            }
        }
    }
    private func curTotal(cat: String) -> Double {
        var t = 0.0
        //print(exp)
        for i in expenseList.filter({ $0.category == cat }) {
            t += i.value
            print("addition")
        }
        return t
    }
    
    //    private func flatten() -> [Expense] {
    //        var t : [Expense] = []
    //        for transaction in expenseList{
    //            t.append(transaction)
    //            print(transaction.account)
    //            print("did append")
    //        }
    //        return t
    //    }
    
    private func totalPrice() -> Double {
        var total = 0.0
        
        for transaction in expenseList{
            total += transaction.value
            
        }
        return total
        //        if (expenseList.count > 0) {
        //            print(expenseList[0].account)
        //            print("made it")
        //            print(expenseList.count)
        //        }
    }
    
}

extension Expenditures {
    func loadData() {
        
        let ref = Database.database().reference()
        ref.child("accounts").observeSingleEvent(of: .value) { snapshot in
            self.tempAccounts = self.makeItems(from: snapshot)
        }
        ref.child("categories").observeSingleEvent(of: .value) { snapshot in
            self.tempCategories = self.makeItems(from: snapshot)
        }
        ref.child("expenditures").observeSingleEvent(of: .value) { snapshot in
            //print("here maybe?")
            let temp = self.createExpense(from: snapshot)
            self.expenseList = temp
            // print("file did load")
            //print(expenseList)
            // self.dataIsFetched = true
        }
    }
    
    func makeItems(from snapshot: DataSnapshot) -> [String] {
        var items = [String]()
        
        if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
            for snap in snapshots {
                if let postDictionary = snap.value as? String {
                    items.append(postDictionary)
                }
            }
        }
        return items
    }
    
    func createExpense(from snapshot: DataSnapshot) -> [Expense]  {
        var tempList = [Expense]()
        //  var temps = [Expense]()
        if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
            for snap in snapshots {
                if let postDictionary = snap.value as? Dictionary<String, AnyObject> {
                    let item = Expense(account: postDictionary["account"] as! String, category: postDictionary["category"] as! String, date: postDictionary["date"] as! String, name: postDictionary["name"] as! String, value: postDictionary["value"] as! Double)
                    tempList.append(item)
                }
            }
        }
        return tempList
    }
}



//struct Categories: View {
//    @State var category: String
//    @State var num: Int
//    @State var width: CGFloat
//    @State var height: CGFloat
//    @State var exp: [Expense]
//
//    var body: some View {
//        // GeometryReader { m in
//        HStack {
//            NavigationLink(destination: ExpenseListByCategory(category: category, expenses:  exp, width: width, height: height, num: exp.count + 1)) {
//                Spacer()
//                ZStack {
//                    RoundedRectangle(cornerRadius: 5).fill(Color.init(red: 0.66, green: 0.66, blue: 0.66)).frame(width: width / 1.2, height: height / 9, alignment: .center)
//                    HStack {
//                        Text(category).foregroundColor(.black).textCase(.uppercase)
//                        Spacer()
//                        HStack {
//                            Text("$" + String(self.curTotal(cat: category))).foregroundColor(.black).fontWeight(.medium)
//                            Image(systemName: "chevron.right")
//                        }
//                    }.frame(width: width / 1.4, height: height / 9, alignment: .center)
//                }
//                Spacer()
//            }
//            NavigationLink(destination: EmptyView()) {
//                EmptyView()
//            }
//        }.onAppear(perform: {
//            print("hi")
//            print(exp)
//            print(num)
//            //print("filtered: ")
//            // print(expenses.filter { $0.category == category })
//        })
//    }
//    private func curTotal(cat: String) -> Double {
//        var t = 0.0
//        print(exp)
//        for i in exp.filter({ $0.category == cat }) {
//            t += i.value
//            print("addition")
//        }
//        return t
//    }
//}

struct ExpenseListByCategory: View {
    @State var category: String
    @State var expenses: [Expense]
    @State var width: CGFloat
    @State var height: CGFloat
    @State var num: Int
    
    var body: some View {
        VStack(spacing: 10){
            Text("Expenses for \n" + category + String(num)).font(.title2).padding(30).textCase(/*@START_MENU_TOKEN@*/.uppercase/*@END_MENU_TOKEN@*/).foregroundColor(.black)
            ForEach(expenses, id: \.self) { i in
                showItems(exp: i, width: width, height: height)
            }
            Spacer()
            
        }.onAppear(perform: {
            print(expenses.count)
        })
    }
    
}


//struct showItems: View {
//    @State var exp: Expense
//    @State var clicked: Bool = false
//    @State var width: CGFloat
//    @State var height: CGFloat
//
//    var body: some View {
//        ZStack {
//            RoundedRectangle(cornerRadius: 5).fill(Color.init(red: 0.66, green: 0.66, blue: 0.66)).frame(width: width / 1.1, height: height / 10, alignment: .center)
//
//            HStack {
//                Button(action: {self.clicked.toggle()}) {
//                    Text(exp.name).foregroundColor(.black)
//                    Spacer()
//                    Text("$" + String(exp.value)).foregroundColor(.black)
//                    Image(systemName: "chevron.right")
//                }.popover(isPresented: $clicked) {
//                    VStack {
//                        Text("Details:" + exp.name)
//                        Spacer()
//                        Text("Name of Transaction: " + exp.name)
//                        Text("Date of Transaction: " + exp.date)
//                        Text("Value of Transaction: " + String(exp.value))
//                        Text("Account of Transaction: " + exp.account)
//                        Text("Category of Transaction: " + exp.account)
//
//                    }
//                }
//            }.frame(width: width / 1.4, height: height / 9, alignment: .center)
//        }
//    }
//}
//

struct showItems: View {
    @State var exp: Expense
    @State var clicked: Bool = false
    @State var width: CGFloat
    @State var height: CGFloat
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5).fill(Color.init(red: 0.66, green: 0.66, blue: 0.66)).frame(width: width / 1.1, height: height / 10, alignment: .center)
            HStack {
                Button(action: {self.clicked.toggle()}) {
                    Text(exp.name).foregroundColor(.black)
                    Spacer()
                    Text("$" + String(exp.value)).foregroundColor(.black)
                    Image(systemName: "chevron.right")
                }.popover(isPresented: $clicked) {
                    VStack(spacing: 10) {
                        Spacer()
                        Text("Details for:" + exp.name).font(.title).underline()
                        Spacer()
                        HStack {
                            Text("Date of Transaction: ").fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                            Spacer()
                            Text(exp.date).underline()
                        }.frame(width: width/1.2)
                        HStack {
                            Text("Value of Transaction: ").fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                            Spacer()
                            Text(String(exp.value)).underline()
                        }.frame(width: width/1.2)
                        HStack {
                            Text("Account of Transaction: ").fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                            Spacer()
                            Text(exp.account).underline()
                        }.frame(width: width/1.2)
                        HStack {
                            Text("Category of Transaction: ").fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                            Spacer()
                            Text(exp.category).underline()
                        }.frame(width: width/1.2)
                        Spacer()
                    }
                }
            }.frame(width: width / 1.2, height: height / 9, alignment: .center)
        }
    }
}


