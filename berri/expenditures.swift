
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
    @State var width: CGFloat
    @State var height: CGFloat
    
    let times = ["DAY", "WEEK", "MONTH", "YEAR", "TOTAL"]
    
    var body: some View {
//        GeometryReader { m in
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
                            RoundedRectangle(cornerRadius: 5).fill(Color.init(red: 0.99, green: 0.66, blue: 0.66)).frame(width: width / 1.2, height: (height / CGFloat(10)) * 2, alignment: .center)
                            VStack {
                                Text((isExpenseView ? ("Spent") : ( "Earned")) + " this " + timeFilter).font(.title3).foregroundColor(.black).textCase(.uppercase)
                                Text("$" + String(filteredData(exp: expenseList) .map({$0.value}).reduce(0, +))).foregroundColor(.black).font(.largeTitle).fontWeight(.heavy)
                            }
                        }
                        ScrollView(.vertical) {
                            ForEach (isExpenseView ? tempCategories : tempIncome, id: \.self) { c in
                                let curArr = filteredData(exp: expenseList, cat: c)
                                //                                if (curArr.count > 2) {
                                //                                    curArr.sorted(by: { $0.convDate > $1.convDate })
                                //                                }
                                VStack {
                                    HStack {
                                        NavigationLink(destination: ExpenseListByCategory(category: c, expenses: curArr, width: width, height: height, tempAccounts: tempAccounts, tempCategories: tempCategories, tempIncome: tempIncome)) {
                                            Spacer()
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 5).fill(Color.init(red: 0.66, green: 0.66, blue: 0.66)).frame(width: width / 1.2, height: height / 9, alignment: .center)
                                                HStack {
                                                    Text(c).foregroundColor(.black).textCase(.uppercase)
                                                    Spacer()
                                                    HStack {
                                                        Text("$" +
                                                             String(format: "%.2f", curArr.map({$0.value}).reduce(0, +))).foregroundColor(.black).fontWeight(.medium)
                                                        Image(systemName: "chevron.right")
                                                    }
                                                }.frame(width: width / 1.4, height: height / 9, alignment: .center)
                                            }
                                            Spacer()
                                        }
                                    }
                                }
                            }.frame(height: height, alignment: .topLeading)
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
            }.navigationViewStyle(DoubleColumnNavigationViewStyle())
     //   }
        
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
        } else {
            temp = initial
        }
        
        return temp.sorted{$0.convDate > $1.convDate}

    }
    
}



struct ExpenseListByCategory: View {
    @State var category: String
    @State var expenses: [Transaction]
    @State var width: CGFloat
    @State var height: CGFloat
    @State var tempAccounts : [String]
    @State var tempCategories : [String]
    @State var tempIncome : [String]
    
    var body: some View {
        VStack(spacing: 0){
            Text("Transactions for \n" + category).font(.title2).padding(30).textCase(/*@START_MENU_TOKEN@*/.uppercase/*@END_MENU_TOKEN@*/).foregroundColor(.black).multilineTextAlignment(.center)
            ForEach(expenses, id: \.self) { i in
                showItems(exp: i, width: width, height: height, tempAccounts: tempAccounts, tempCategories: tempCategories, tempIncome: tempIncome)
            }
            Spacer()
        }.navigationBarHidden(false)
    }
}

struct showItems: View {
    @ObservedObject var exp: Transaction
    @State var clicked: Bool = false
    @State var editChoice: Bool = false
    @State var width: CGFloat
    @State var height: CGFloat
    @State var tempAccounts : [String]
    @State var tempCategories : [String]
    @State var tempIncome : [String]
    
    static let itemDateFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter
    }()
    
    var body: some View {
        ZStack {
            exp.isIncome ? RoundedRectangle(cornerRadius: 5).fill(Color.init(red: 0.66, green: 0.66, blue: 0.66)).frame(width: width / 1.1, height: height / 10, alignment: .center) :
                RoundedRectangle(cornerRadius: 5).fill(Color.init(red: 0.33, green: 0.33, blue: 0.66)).frame(width: width / 1.1, height: height / 10, alignment: .center)
            HStack {
                Button(action: {self.clicked.toggle()}) {
                    Text(exp.name).foregroundColor(.black)
                    Spacer()
                    Text("$" + String(format: "%.2f", abs(exp.value))).foregroundColor(.black)
                    Image(systemName: "chevron.right")
                }}.frame(width: width / 1.2, height: height / 9, alignment: .center)
            
        }.popover(isPresented: $clicked) {
            NavigationView {
                VStack(spacing: 10) {
                    Spacer()
                    HStack {
                        Text("Details for: ").font(.title)
                        TextField(exp.name, text: $exp.name).font(.title).border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/).padding(5)
                    }.multilineTextAlignment(.center).frame(width: width / 1.2)
                    Spacer()
                    HStack {
                        Text("Date of Transaction: ").fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                        Spacer()
                        DatePicker(selection: $exp.convDate, in: ...Date(), displayedComponents: .date) {
                        }
                    }.frame(width: width/1.2)
                    HStack {
                        Text("Value of Transaction: ").fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                        Spacer()
                        TextField(String(exp.value), value: $exp.value, formatter: NumberFormatter()).border(Color.black).padding(5)
                    }.frame(width: width/1.2)
                    HStack {
                        Text("Account of Transaction: ").fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                        Spacer()
                            Picker(exp.account, selection: $exp.account) {
                                ForEach(tempAccounts, id: \.self) {
                                    Text($0)
                                }
                        }.pickerStyle(MenuPickerStyle()).frame(minWidth: 0, maxWidth: width / 2)
                        
                    }.frame(width: width/1.2)
                    HStack {
                        Text("Category of Transaction: ").fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                        Spacer()
                        Picker(exp.category, selection: $exp.category) {
                            exp.category == "" ? Text(exp.category) : nil
                            ForEach(tempCategories, id: \.self) {
                                Text($0)
                            }
                        }.pickerStyle(MenuPickerStyle()).frame(minWidth: 0, maxWidth: width / 2)
                    }.frame(width: width/1.2)
                    exp.isIncome ? HStack {
                        Text("Income Type of Transaction: ").fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                        Spacer()
                        Picker(exp.incomeType, selection: $exp.incomeType) {
                            exp.incomeType == "" ? Text(exp.incomeType) : nil
                            ForEach(tempIncome, id: \.self) {
                                Text($0)
                            }
                        }.pickerStyle(MenuPickerStyle())
                    }.frame(width: width/1.2) : nil
                    Spacer()
                    Button(action: {
                        let ref = Database.database().reference()
                        exp.date = showItems.itemDateFormat.string(from: exp.convDate)
                        exp.isIncome ?
                            ref.child("income").child(exp.id).setValue(["account": exp.account, "category": exp.category, "date": exp.date , "incomeType": exp.incomeType, "name": exp.name, "value": Double(abs(exp.value))]) :  ref.child("expenditures").child(exp.id).setValue(["account": exp.account, "category": exp.category, "date": exp.date, "name": exp.name, "value": Double(exp.value)])
                        self.clicked.toggle()
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 5).fill(Color.init(red: 0.33, green: 0.50, blue: 0.43)).frame(width: width / 1.5, height: height / 7, alignment: .center)
                            Text("Submit")
                        }
                    }
                }
            }
        }.frame(width: width / 1.2, height: height / 9, alignment: .center)
    }
}
