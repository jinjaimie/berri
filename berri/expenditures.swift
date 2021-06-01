
import Foundation
import SwiftUI
import Firebase

struct Expenditures: View {
    @State var tempAccounts = [String]()
    @State var tempCategories = [String]()
    @State var tempIncome = [String]()
    @State var expenseList = [Transaction]()
    @State var expenses : [Transaction]
    @State var timeFilter = "MONTH"
    @State var reconList : [Transaction]
    @State var curView = "Expenditures"
    @State var incomeList : [Transaction]
    @State var isExpenseView: Bool = true
    
    let times = ["DAY", "WEEK", "MONTH", "YEAR"]
    
    var body: some View {
        GeometryReader { m in
            NavigationView {
                VStack(spacing: 10) {
                    HStack {
                        ForEach (times, id: \.self) { t in
                            Button {self.timeFilter = t} label: {
                                (t != timeFilter) ? Text(t).font(.title3).foregroundColor(.black) : Text(t).underline().font(.title3).foregroundColor(.black)
                            }
                        }
                    }
                    VStack(spacing: 5) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 5).fill(Color.init(red: 0.99, green: 0.66, blue: 0.66)).frame(width: m.size.width / 1.2, height: (m.size.height / CGFloat(10)) * 2, alignment: .center)
                            VStack {
                                Text((isExpenseView ? ("Spent") : ( "Earned")) + " this " + timeFilter).font(.title3).foregroundColor(.black).textCase(.uppercase)
                                Text("$" + String(filteredData(exp: expenseList) .map({$0.value}).reduce(0, +))).foregroundColor(.black).font(.largeTitle).fontWeight(.heavy)
                            }
                        }
                        ScrollView(.vertical) {
                            ForEach (isExpenseView ? tempCategories : tempIncome, id: \.self) { c in
                                let curArr = filteredData(exp: expenseList, cat: c)
                                 VStack {
                                    HStack {
                                        NavigationLink(destination: ExpenseListByCategory(category: c, expenses: curArr, width: m.size.width, height: m.size.height)) {
                                            Spacer()
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 5).fill(Color.init(red: 0.66, green: 0.66, blue: 0.66)).frame(width: m.size.width / 1.2, height: m.size.height / 9, alignment: .center)
                                                HStack {
                                                    Text(c).foregroundColor(.black).textCase(.uppercase)
                                                    Spacer()
                                                    HStack {
                                                        Text("$" + String(curArr.map({$0.value}).reduce(0, +))).foregroundColor(.black).fontWeight(.medium)
                                                        Image(systemName: "chevron.right")
                                                    }
                                                }.frame(width: m.size.width / 1.4, height: m.size.height / 9, alignment: .center)
                                            }
                                            Spacer()
                                        }
                                    }
                                }
                            }.frame(height: m.size.height, alignment: .topLeading)
                        }
                    }
                }.navigationBarItems(leading: {
                    Menu {
                        Button(action: {
                            self.expenseList = self.expenses
                            self.curView = "Expenses"
                            self.isExpenseView = true
                        }) {
                            Text("Expenses")
                        }
                        Button(action: {
                            self.expenseList = self.reconList
                            self.curView = "Recon"
                            self.isExpenseView = true
                        }) {
                            Text("Recon")
                        }
                        Button(action: {
                            self.expenseList = self.incomeList
                            self.curView = "Income"
                            self.isExpenseView = false
                        }) {
                            Text("Income")
                        }} label: {
                            HStack {
                                Spacer()
                            HStack {
                                Text(curView).font(.title)
                                Image(systemName: "chevron.down")
                            }
                                Spacer()
                            }
                        }
                }())
            }.navigationViewStyle(StackNavigationViewStyle())
        }
        
    }
    
    private func filteredData(exp: [Transaction], cat: String = "") -> [Transaction] {
        var initial : [Transaction] = exp
        var temp : [Transaction] = []
        let date1 = Date()
        if (cat != "" && self.isExpenseView) {
            initial = initial.filter({$0.category == cat})
        }
        if (cat != "" && !self.isExpenseView) {
            initial = initial.filter({$0.incomeType == cat})
        }
        
        if (self.timeFilter == "DAY") {
            for i in initial {
                let date2 = i.convDate
                Calendar.current.isDate(date1, inSameDayAs: date2) ? temp.append(i) : nil
            }
        } else if (self.timeFilter == "WEEK") {
            for i in initial {
                let date2 = i.convDate
                Calendar.current.isDate(date1, equalTo: date2, toGranularity: .weekOfYear) ? temp.append(i) : nil
            }
        } else if (self.timeFilter == "MONTH") {
            for i in initial {
                let date2 = i.convDate
                Calendar.current.isDate(date1, equalTo: date2, toGranularity: .month) ? temp.append(i) : nil
            }
        } else if (self.timeFilter == "YEAR") {
            for i in initial {
                let date2 = i.convDate
                Calendar.current.isDate(date1, equalTo: date2, toGranularity: .year) ? temp.append(i) : nil
            }
        }
        return temp
    }
    
}



struct ExpenseListByCategory: View {
    @State var category: String
    @State var expenses: [Transaction]
    @State var width: CGFloat
    @State var height: CGFloat
    
    var body: some View {
        VStack(spacing: 0){
            Text("Transactions for \n" + category).font(.title2).padding(30).textCase(/*@START_MENU_TOKEN@*/.uppercase/*@END_MENU_TOKEN@*/).foregroundColor(.black).multilineTextAlignment(.center)
            ForEach(expenses, id: \.self) { i in
                showItems(exp: i, width: width, height: height)
            }
            Spacer()
        }.navigationBarHidden(false)
    }
}

struct CategoryView: View {
    @State var c: String
    @State var curArr: [Transaction]
    @State var width: CGFloat
    @State var height: CGFloat
    
    var body: some View {
        VStack {
            HStack {
                NavigationLink(destination: ExpenseListByCategory(category: c, expenses: curArr, width: width, height: height)) {
                    Spacer()
                    ZStack {
                        RoundedRectangle(cornerRadius: 5).fill(Color.init(red: 0.66, green: 0.66, blue: 0.66)).frame(width: width / 1.2, height: height / 9, alignment: .center)
                        HStack {
                            Text(c).foregroundColor(.black).textCase(.uppercase)
                            Spacer()
                            HStack {
                                Text("$" + String(curArr.map({$0.value}).reduce(0, +))).foregroundColor(.black).fontWeight(.medium)
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

struct showItems: View {
    @State var exp: Transaction
    @State var clicked: Bool = false
    @State var width: CGFloat
    @State var height: CGFloat
    
    var body: some View {
        ZStack {
            exp.isIncome ? RoundedRectangle(cornerRadius: 5).fill(Color.init(red: 0.66, green: 0.66, blue: 0.66)).frame(width: width / 1.1, height: height / 10, alignment: .center) :
                RoundedRectangle(cornerRadius: 5).fill(Color.init(red: 0.33, green: 0.33, blue: 0.66)).frame(width: width / 1.1, height: height / 10, alignment: .center)
            HStack {
                Button(action: {self.clicked.toggle()}) {
                    Text(exp.name).foregroundColor(.black)
                    Spacer()
                    Text("$" + String(exp.value)).foregroundColor(.black)
                    Image(systemName: "chevron.right")
                }.popover(isPresented: $clicked) {
                    VStack(spacing: 10) {
                        Spacer()
                        HStack {
                            Text("Details for: ").font(.title)
                            Text(exp.name).font(.title).underline()
                        }.multilineTextAlignment(.center)
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
                        exp.isIncome ? HStack {
                            Text("Income Type of Transaction: ").fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                            Spacer()
                            Text(exp.incomeType).underline()
                        }.frame(width: width/1.2) : nil
                        Spacer()
                    }
                }
            }.frame(width: width / 1.2, height: height / 9, alignment: .center)
        }
    }
}
