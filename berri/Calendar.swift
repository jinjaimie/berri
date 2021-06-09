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

    @State var expenseList = [MTransaction]()
   
    @State var timeFilter = "MONTH"
    @State var curView = ["All Expenditures (E)", "All Income (P+I)", "True Income (I)", "Payback Only", "Transfer", "Reconed Expenses (E-P)"]
    @State var viewInt = 0
    
    @State var width: CGFloat
    @State var height: CGFloat
    
    @StateObject var fbHandler: FirebaseHandler
    
    @State var type: String = "By Month"
    @State var typeView: [String] = ["By Month", "By Categories"]
    
    @State var chosenList = [String]()
    
    var body: some View {
        VStack {
            Picker("Type", selection: $type) {
                ForEach(typeView, id: \.self) {
                    Text($0)
                }
            }.pickerStyle(SegmentedPickerStyle()).frame(width: width / 1.5)
            ScrollView {
                VStack {
                    ForEach(getYearRange(), id: \.self) { year in
                        let filterArr = filteredYear(year: year)
                        let choose = fbHandler.tempCategories + fbHandler.tempIncome
                        if (type == "By Month") {
                            NavigationLink(destination: ByMonth(arr: filterArr, width: width, height: height) ) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 5).fill(Color("MainColor")).frame(width: width / 1.2, height: (height / CGFloat(10)) * 2, alignment: .center)
                                    VStack {
                                        Text(String(year)).bold().foregroundColor(.black)
                                        Text("$" + String(format:  "%.2f", filterArr.map({$0.value}).reduce(0,+))).foregroundColor(.black)
                                    }
                                }
                            }
                        } else {
                            NavigationLink(destination: ByCategorySimple(arr: filterArr, chosenList: choose, width: width, height: height) ) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 5).fill(Color("MainColor")).frame(width: width / 1.2, height: (height / CGFloat(10)) * 2, alignment: .center)
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
        }
    }
    
    func getYearRange() -> [Int] {
        let total = (fbHandler.reconList + fbHandler.incomeList).filter({$0.category != "Transfer"}).map({$0.convDate}).sorted(by: {$0 > $1})
        if (total.count != 0) {
            let last : Date! = total.last
            let first : Date! = total.first
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy"
            
            let arr  = Array(Int(dateFormatter.string(from: last))!...Int(dateFormatter.string(from: first))!)
            
            return arr
        } else {
            return []
        }
    }
    
    func filteredYear(year: Int) -> [MTransaction] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        let total = (fbHandler.reconList + fbHandler.incomeList).filter({dateFormatter.string(from: $0.convDate) == String(year)})
       // print(total.map({$0.convDate}))
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
                NavigationLink(destination: ExpenseListByCategory(category: m, expenses: filterArr, width: width, height: height, fbHandler: handler)) {
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
        var total = self.arr.filter({Calendar.current.component(.month, from: $0.convDate) == (months.index(of: month)! - 1)})
        return total
    }
}


struct ByCategorySimple : View {
    @State var arr : [MTransaction]
    @State var chosenList : [String]
    @State var width: CGFloat
    @State var height: CGFloat
    
    @StateObject var handler = FirebaseHandler()
    
    var body: some View {
        ScrollView{
        VStack {
            ForEach (chosenList, id: \.self) { c in
                let curArr = arr.filter({$0.category == c || $0.incomeType == c})
                VStack {
                    HStack {
                        NavigationLink(destination: ExpenseListByCategory(category: c, expenses: curArr, width: width, height: height, fbHandler: handler)) {
                            Spacer()
                            ZStack {
                                RoundedRectangle(cornerRadius: 5).fill(Color("IncomeColor")).frame(width: width / 1.2, height: height / 9, alignment: .center)
                                HStack {
                                    Text(c).foregroundColor(.black).textCase(.uppercase)
                                    Spacer()
                                    HStack {
                                        Text("$" +
                                                String(format: "%.2f", abs(curArr.map({$0.value}).reduce(0, +)))).foregroundColor(.black).fontWeight(.medium)
                                        Image(systemName: "chevron.right")
                                    }
                                }.frame(width: width / 1.4, height: height / 9, alignment: .center)
                            }
                            Spacer()
                        }
                    }
                    
                }
            }
        }
        }
    }
}
