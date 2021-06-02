//
//  ContentView.swift
//  berri
//
//  Created by Saatvik Arya on 5/26/21.
//

import SwiftUI
import Firebase

struct ContentView: View {

    let main:UIColor = UIColor(red: 0.937, green: 0.824, blue: 0.827, alpha: 1)
    let accent:Color = Color(red: 0.64, green: 0.36, blue: 0.25)
    @State var tempAccounts = [String]()
    @State var tempCategories = [String]()
    @State var expenseList = [Transaction]()
    @State var incomeList = [Transaction]()
    @State var reconList = [Transaction]()
    @State var tempIncome = [String]()
    

    var body: some View {
        NavigationView {
            TabView {
                ZStack {
                  
                }.tabItem { Label("Account", systemImage: "person.fill") }
                .tag(1)
                
                ZStack {
                  Expenditures(tempAccounts: tempAccounts, tempCategories: tempCategories, tempIncome: tempIncome, expenseList: expenseList, expenses: expenseList, reconList: reconList, incomeList: incomeList)
                }.tabItem { Label("Expenses", systemImage: "dollarsign.circle.fill").foregroundColor(.white) }
                .tag(2)
                
                ZStack {
                  AddMoney(accounts: tempAccounts, categories: tempCategories)
                }.tabItem { Label("Add", systemImage: "plus").foregroundColor(.white) }
                .tag(3)
                
                ZStack {
                    SettingView().tag(1)
                }.tabItem { Label("Settings", systemImage: "gear") }
                .tag(4)
            }.accentColor(accent)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Image("berri")
                }
            }
            .onAppear() {
                UITabBar.appearance().barTintColor = main
            }
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct SettingView: View {
    var body: some View {
        VStack (spacing: 5) {
            NavigationLink(
                destination: AccountForm()) {
                    Text("Add an account").padding()
            }
            NavigationLink(
                destination: CategoryForm()) {
                Text("Add a category").padding()
            }
        }

extension ContentView {
    func loadData() {
        let ref = Database.database().reference()
        ref.child("accounts").observeSingleEvent(of: .value) { snapshot in
            self.tempAccounts = self.makeItems(from: snapshot)
        }
        ref.child("categories").observeSingleEvent(of: .value) { snapshot in
            self.tempCategories = self.makeItems(from: snapshot)
        }
        ref.child("incomeTypes").observeSingleEvent(of: .value) { snapshot in
            self.tempIncome = self.makeItems(from: snapshot)
        }
        ref.child("expenditures").observeSingleEvent(of: .value) { snapshot in
            let temp = self.createTransactions(from: snapshot, isIncome: false)
            self.expenseList = temp
        }
        ref.child("income").observeSingleEvent(of: .value) { snapshot in
            let temp = self.createTransactions(from: snapshot, isIncome: true)
            self.incomeList = temp
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
    
    func createTransactions(from snapshot: DataSnapshot, isIncome: Bool) -> [Transaction]  {
        var tempList = [Transaction]()
        if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
            print(snapshots.count)
            for snap in snapshots {
                if let postDictionary = snap.value as? Dictionary<String, AnyObject> {
                    let item = Transaction(id: Int(snap.key)!, account: postDictionary["account"] as! String, date: postDictionary["date"] as! String, name: postDictionary["name"] as! String, value: postDictionary["value"] as! Double, category: postDictionary["category"] as! String)
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MM/dd/yyyy"
                    item.convDate = dateFormatter.date(from: item.date)!
                    // print(item.convDate, " ::: ", item.date)
                    if (isIncome) {
                        item.isIncome = true
                        item.incomeType = postDictionary["incomeType"] as! String
                    }
                    if (item.category != "") {
                        isIncome ? item.value = -item.value : nil
                        reconList.append(item)
                    }
                    if (isIncome && item.category == "" || !isIncome && item.category != "") {
                        tempList.append(item)
                    }
                }
            }
        }
        return tempList
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
