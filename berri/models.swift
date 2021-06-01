//
//  models.swift
//  berri
//
//  Created by stlp on 5/29/21.
//

import Foundation
import SwiftUI
import Firebase

//class Expense: NSObject  {
//    var account: String
//    var category: String
//    var date: String
//    var name: String
//    var value: Double
//    var convDate: Date = Date()
//    var isIncome: Bool = false
//
//    init(account: String, category: String, date: String, name: String, value: Double) {
//        self.account = account
//        self.category = category
//        self.date = date
//        self.name = name
//        self.value = value
//    }
//
//}
//
//struct Income: Identifiable, Decodable {
//    var id: String {name}
//    var account: String
//    var date: String
//    var name: String
//    var value: Double
//    var incomeType: String
//    var category: String
//    var convDate: Date = Date()
//
//    init(account: String, date: String, name: String, value: Double, incomeType: String, category: String) {
//        self.account = account
//        self.date = date
//        self.name = name
//        self.value = value
//        self.incomeType = incomeType
//        self.category = category
//    }
//}


class Transaction: NSObject {
    var id: String {name}
    var account: String
    var date: String
    var name: String
    var value: Double
    var incomeType: String = ""
    var category: String
    var convDate: Date = Date()
    var isIncome: Bool = false

    init(account: String, date: String, name: String, value: Double, category: String) {
        self.account = account
        self.date = date
        self.name = name
        self.value = value
        self.category = category
    }
    
    init(account: String, date: String, name: String, value: Double, incomeType: String, category: String) {
        self.account = account
        self.date = date
        self.name = name
        self.value = value
        self.incomeType = incomeType
        self.category = category
    }
}
