//
//  models.swift
//  berri
//
//  Created by stlp on 5/29/21.
//

import Foundation
import SwiftUI
import Firebase

class Transaction: NSObject, ObservableObject {
    @Published var id: String
    @Published var account: String
    @Published var date: String
    @Published var name: String
    @Published var value: Double
    @Published var incomeType: String = ""
    @Published var category: String
    @Published var convDate: Date = Date()
    @Published var isIncome: Bool = false

    init(id: String, account: String, date: String, name: String, value: Double, category: String) {
        self.id = id
        self.account = account
        self.date = date
        self.name = name
        self.value = value
        self.category = category
    }
    
    init(id: String, account: String, date: String, name: String, value: Double, incomeType: String, category: String) {
        self.id = id
        self.account = account
        self.date = date
        self.name = name
        self.value = value
        self.incomeType = incomeType
        self.category = category
    }
}

class NewTransaction: ObservableObject {
    @Published var accountOut: String = ""
    @Published var accountIn: String = ""
    @Published var date: String = ""
    @Published var name: String = ""
    @Published var value: Double = 0.0
    @Published var incomeType: String = ""
    @Published var category: String = ""
    @Published var convDate: Date = Date()
}
