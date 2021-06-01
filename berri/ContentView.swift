//
//  ContentView.swift
//  berri
//
//  Created by Saatvik Arya on 5/26/21.
//

import SwiftUI
import Firebase

struct ContentView: View {
    @State var tempAccounts = [String]()
    @State var tempCategories = [String]()
    @State var expenseList = [Transaction]()
    @State var incomeList = [Transaction]()
    @State var reconList = [Transaction]()
    @State var tempIncome = [String]()
    
    var body: some View {
        TabView {
            WriteTest()
                .padding().tabItem {
                    Image(systemName: "hand.thumbsup.fill")
                    Text("Home")
                }.tag(2)
            
//            Expenditures(tempAccounts: tempAccounts, tempCategories: tempCategories, expenseList: expenseList).tabItem {
//                Image(systemName: "hand.thumbsup.fill")
//                Text("Good")
//            }.tag(2)
            Expenditures(tempAccounts: tempAccounts, tempCategories: tempCategories, tempIncome: tempIncome, expenseList: expenseList, expenses: expenseList, reconList: reconList, incomeList: incomeList).tabItem {
                Image(systemName: "hand.thumbsup.fill")
            }.tag(1)
        }.onAppear(perform: loadData)
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
    
//    func createIncome(from snapshot: DataSnapshot) -> [Transaction]  {
//        var tempList = [Transaction]()
//        if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
//            for snap in snapshots {
//                if let postDictionary = snap.value as? Dictionary<String, AnyObject> {
//                    // print(postDictionary)
//                    var item = Transaction(account: postDictionary["account"] as! String, date: postDictionary["date"] as! String, name: postDictionary["name"] as! String, value: postDictionary["value"] as! Double, incomeType: postDictionary["incomeType"] as! String, category: postDictionary["category"] as! String)
//                    let dateFormatter = DateFormatter()
//                    dateFormatter.dateFormat = "MM/dd/yyyy"
//                    item.convDate = dateFormatter.date(from: item.date)!
//                    tempList.append(item)
//                }
//            }
//        }
//        return tempList
//    }
    
//    func sortRecon() -> [Transaction] {
//        var temp = [Transaction]()
//        for i in self.incomeList.filter({$0.category != ""}) {
//            var converted = Transaction(account: i.account, date: i.date, name: i.name, value: -i.value, category: i.category)
//            converted.isIncome = true
//            converted.convDate = i.convDate
//            temp.append(converted)
//        }
//        return temp
//    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
