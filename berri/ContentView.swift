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
        GeometryReader { m in
        NavigationView {
            TabView {
                ZStack {
                    
                }.tabItem { Label("Account", systemImage: "person.fill") }
                .tag(1)
                
                ZStack {
                    Expenditures(tempAccounts: tempAccounts, tempCategories: tempCategories, tempIncome: tempIncome, expenseList: expenseList, expenses: expenseList, reconList: reconList, incomeList: incomeList, width: m.size.width, height: m.size.height)
                }.tabItem { Label("Expenses", systemImage: "dollarsign.circle.fill").foregroundColor(.white) }
                .tag(2)
                
                ZStack {
                    ConfirmAccount(width: m.size.width, height: m.size.height, accounts: tempAccounts, categories: tempCategories, incomes: tempIncome)
                }.tabItem {
                    Label("Add", systemImage: "plus").foregroundColor(.black)
                }.tag(3)
                ZStack {
                    SettingView()
                }.tabItem { Label("Settings", systemImage: "gear") }
                .tag(4)
            }.accentColor(accent).onAppear(perform: loadData)
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
    }
    
}
extension ContentView {
    func loadData() {
        let ref = Database.database().reference()
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
        
        ref.child("accounts").observeSingleEvent(of: .value) { snapshot in
            let temp = self.createAccount(from: snapshot)
            var temp2 = [String]()
            for i in temp.keys {
                temp2.append(String(i))
            }
            self.tempAccounts = temp2
          //  print(tempAccounts)
           // print(tempAccounts[0])
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
    
    func createAccount(from snapshot: DataSnapshot) -> Dictionary<String, Double> {
        var items = Dictionary<String, Double>()
        if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
            for snap in snapshots {
                if let postDictionary = snap.value as? Dictionary<String, AnyObject> {
                    items[snap.key] = postDictionary["amount"] as? Double
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
                    let item = Transaction(id: String(snap.key), account: postDictionary["account"] as! String, date: postDictionary["date"] as! String, name: postDictionary["name"] as! String, value: postDictionary["value"] as! Double, category: postDictionary["category"] as! String)
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MM/dd/yyyy"
                    item.convDate = dateFormatter.date(from: item.date)!
                    if (isIncome) {
                        item.isIncome = true
                        item.incomeType = postDictionary["incomeType"] as! String
                    }
                    if (item.category != "") {
                        isIncome ? item.value = -(item.value) : nil
                        reconList.append(item)
                        print(item.name, " : ", item.value)
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
      //  ConfirmAccount(width: CGFloat(360), height: CGFloat(800), accounts: ["Checking", "Savings", "Other", "Another"], categories: ["Test1", "Test2", "Test4", "Test5", "Test6"])
        
    }
}
