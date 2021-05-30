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
    // @State var expenseList = [Expense]()
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
                    VStack(spacing: 10) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 5).fill(Color.init(red: 0.99, green: 0.66, blue: 0.66)).frame(width: m.size.width / 1.2, height: (m.size.height / CGFloat((tempCategories.count + 3))) * 2, alignment: .center)
                            VStack {
                                Text("Spent").font(.title3).foregroundColor(.black).textCase(.uppercase)
                                Text("$260.67").foregroundColor(.black).font(.largeTitle).fontWeight(.heavy)
                            }
                        }
                        Spacer()
                        ScrollView(.vertical) {
                            ForEach (tempCategories, id: \.self) { c in
                                Categories(category: c, num: tempCategories.count, width: m.size.width, height: m.size.height, expenses: expenseList.filter({$0.category == c}))
                            }
                        }
                    }
                }.navigationBarHidden(true).frame(height: m.size.height).onAppear(perform: loadData)
            }
            
        }
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
            _ = self.createExpense(from: snapshot)
            print(expenseList)
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
    
    func createExpense(from snapshot: DataSnapshot) {
        // var items = [Expense]()
        self.expenseList = []
        if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
            for snap in snapshots {
                if let postDictionary = snap.value as? Dictionary<String, AnyObject> {
                    let item = Expense(account: postDictionary["account"] as! String, category: postDictionary["category"] as! String, date: postDictionary["date"] as! String, name: postDictionary["name"] as! String, value: postDictionary["value"] as! Double)
                    self.expenseList.append(item)
                }
            }
        }
        //           return items
    }
}



struct Categories: View {
    @State var category: String
    @State var num: Int
    @State var width: CGFloat
    @State var height: CGFloat
    @State var expenses: [Expense]
    
    var body: some View {
        // GeometryReader { m in
        HStack {
            NavigationLink(destination: ExpenseListByCategory(category: category, expenses:  expenses.filter { $0.category == category })) {
                Spacer()
                ZStack {
                    RoundedRectangle(cornerRadius: 5).fill(Color.init(red: 0.66, green: 0.66, blue: 0.66)).frame(width: width / 1.2, height: height / 9, alignment: .center)
                    HStack {
                        Text(category).foregroundColor(.black).textCase(.uppercase)
                        Spacer()
                        HStack {
                            Text("$" + String(43.01)).foregroundColor(.black).fontWeight(.medium)
                            Image(systemName: "chevron.right")
                        }
                    }.frame(width: width / 1.4, height: height / 9, alignment: .center)
                }
                Spacer()
            }
        }
        // }
    }
}

struct ExpenseListByCategory: View {
    @State var category: String
    @State var expenses: [Expense]
    
    var body: some View {
        VStack {
            Text("Hello " + category)
            ForEach(expenses, id: \.self) { i in
                showItem(exp: i)
            }
        }
    }
}


struct showItem: View {
    @State var exp: Expense
    
    var body: some View {
        
        HStack {
            
            Text(exp.account)
            Text(exp.date)
//            Text(exp.category)
//            Text(exp.name)
//            Text(exp.value)
        }
    }
}
