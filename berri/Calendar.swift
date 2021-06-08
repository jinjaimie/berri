//
//  Calendar.swift
//  berri
//
//  Created by stlp on 6/8/21.
//
import Foundation
import SwiftUI
import Firebase
import SwiftUIKit

struct CalendarView: View {
    @State var tempAccounts = [String]()
    @State var tempCategories = [String]()
    @State var tempIncome = [String]()
    @State var expenseList = [MTransaction]()
    
    @State var expenses : [MTransaction]
    @State var timeFilter = "MONTH"
    @State var reconList : [MTransaction]
    @State var curView = ["All Expenditures (E)", "All Income (P+I)", "True Income (I)", "Payback Only", "Transfer", "Reconed Expenses (E-P)"]
    @State var viewInt = 0
    @State var incomeList : [MTransaction]
    @State var width: CGFloat
    @State var height: CGFloat
    @StateObject var fbHandler: FirebaseHandler
    
    @State var chosenList = [String]()
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(getYearRange(), id: \.self) { year in
                    let filterArr = filteredYear(year: year)
                    NavigationLink(destination: ByMonth(arr: filterArr, width: width, height: height)){
                        ZStack {
                            RoundedRectangle(cornerRadius: 5).fill(Color("MainColor")).frame(width: width / 1.2, height: (height / CGFloat(10)) * 2.5, alignment: .center)
                            VStack {
                                Text(String(year)).bold().foregroundColor(.black)
                                Text("$" + String(format:  "%.2f", filterArr.map({$0.value}).reduce(0,+))).foregroundColor(.black)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func getYearRange() -> [Int] {
        let total = (reconList + incomeList).filter({$0.category != "Transfer"}).map({$0.convDate}).sorted(by: {$0 > $1})
        let last : Date! = total.last
        let first : Date! = total.first
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        
        let arr  = Array(Int(dateFormatter.string(from: last))!...Int(dateFormatter.string(from: first))!)
        
        return arr
    }
    
    func filteredYear(year: Int) -> [MTransaction] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        let total = (reconList + incomeList).filter({dateFormatter.string(from: $0.convDate) == String(year)})
        print(total.map({$0.convDate}))
        return total
    }
    
}


struct ByMonth : View {
    @State var arr : [MTransaction]
    
    @State var width: CGFloat
    @State var height: CGFloat
    
    @StateObject var handler = FirebaseHandler()
    @State var months : [String] = Calendar.current.monthSymbols
    
    var body: some View {
        ScrollView {
            ForEach(months, id: \.self) { m in
                let filterArr = filteredMonths(month: m)
                NavigationLink(destination: ExpenseListByCategory(category: m, expenses: filterArr, width: width, height: height, tempAccounts: handler.tempAccount, tempCategories: handler.tempCategories, tempIncome: handler.tempIncome, fbHandler: handler)) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 5).fill(Color("MainColor")).frame(width: width / 1.1, height: (height / CGFloat(10)) * 2, alignment: .center)
                        VStack {
                            Text(String(m)).bold().foregroundColor(.black)
                            Text("$" + String(format:  "%.2f", filterArr.map({$0.value}).reduce(0,+))).foregroundColor(.black)
                        }
                    }
                }
            }
            }
        }
        
        func filteredMonths(month: String) -> [MTransaction] {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy"
            var total = self.arr.filter({Calendar.current.component(.month, from: $0.convDate) == months.index(of: month)})
            print(total.map({$0.convDate}))
            return total
        }
    }
