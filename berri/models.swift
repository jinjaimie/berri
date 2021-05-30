//
//  models.swift
//  berri
//
//  Created by stlp on 5/29/21.
//

import Foundation
import SwiftUI
import Firebase

class Expense: NSObject  {
    var account: String
    var category: String
    var date: String
    var name: String
    var value: Double
    
    init(account: String, category: String, date: String, name: String, value: Double) {
        self.account = account
        self.category = category
        self.date = date
        self.name = name
        self.value = value
    }
    
}
//
//struct Model: Identifiable {
//    @Published var id: String {totalExpenses}
//    @Published var totalExpenses: [Expense] = []
//    init() {
//        Database.database().reference().child("expenditures").observeSingleEvent(of: .value) { snapshot in
//            self.totalExpenses = self.createExpense(from: snapshot)
//            print(self.totalExpenses)
//        }
//    }
//
//    func createExpense(from snapshot: DataSnapshot) -> [Expense] {
//        var items = [Expense]()
//        if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
//            for snap in snapshots {
//                if let postDictionary = snap.value as? Dictionary<String, AnyObject> {
//                    let item = Expense(account: postDictionary["account"] as! String, category: postDictionary["category"] as! String, date: postDictionary["date"] as! String, name: postDictionary["name"] as! String, value: postDictionary["value"] as! Double)
//                    items.append(item)
//                }
//            }
//        }
//        return items
//    }
//}


struct Payday: Identifiable, Decodable {
    var id: String {name}
    var account: String
    var category: String
    var date: Date
    var name: String
    var value: Double
    var income: String
}
