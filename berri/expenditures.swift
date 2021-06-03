
import Foundation
import SwiftUI
import Firebase
import SwiftUIKit

struct Expenditures: View {
    @State var tempAccounts = [String]()
    @State var tempCategories = [String]()
    @State var tempIncome = [String]()
    @State var expenseList = [Transaction]()
    
    @State var expenses : [Transaction]
    @State var timeFilter = "MONTH"
    @State var reconList : [Transaction]
    @State var curView = ["All Expenditures (E)", "All Income (P+I)", "True Income (I)", "Payback Only", "Transfer", "Reconed Expenses (E-P)"]
    @State var viewInt = 0
    @State var incomeList : [Transaction]
    @State var width: CGFloat
    @State var height: CGFloat
    
    @State var chosenList = [String]()
    
    let times = ["DAY", "WEEK", "MONTH", "YEAR", "TOTAL"]
    
    var body: some View {
        //        NavigationView {
        VStack(spacing: 10) {
            HStack {
                Menu {
                    Button(action: {
                        self.expenseList = self.expenses
                        self.viewInt = 0
                        self.chosenList = self.tempCategories
                       
                    }) {
                        Text(curView[0])
                    }
                    Button(action: {
                        self.expenseList = self.reconList
                        self.viewInt = 5
                        self.chosenList = self.tempCategories
                    }) {
                        Text(curView[5])
                    }
                    Button(action: {
                        self.expenseList = self.reconList.filter({$0.isIncome == true}) +  self.incomeList
                        self.viewInt = 1
                        self.chosenList = self.tempCategories + self.tempIncome
                       
                    }) {
                        Text(curView[1])
                    }
                    Button(action: {
                        self.expenseList = self.incomeList
                        self.viewInt = 2
                        self.chosenList = self.tempIncome
                    }) {
                        Text(curView[2])
                    }
                    Button(action: {
                        self.expenseList = self.reconList.filter({$0.isIncome == true})
                        self.viewInt = 3
                        self.chosenList = self.tempCategories
                    }) {
                        Text(curView[3])
                    }
                    Button(action: {
                        self.expenseList = self.expenses.filter({$0.category == "Transfer"})
                        self.viewInt = 4
                        self.chosenList = ["Transfer"]
                    }) {
                        Text(curView[4])
                    }
                } label: {
                    HStack {
                        Text(curView[viewInt]).font(.title3)
                        Image(systemName: "chevron.down")
                    }
                }
            }
            
            HStack {
                ForEach (times, id: \.self) { t in
                    Button {self.timeFilter = t} label: {
                        (t != timeFilter) ? Text(t).font(.title3).foregroundColor(.black) : Text(t).underline().font(.title3).foregroundColor(.black)
                    }
                }
            }
            VStack(spacing: 5) {
                ZStack {
                    RoundedRectangle(cornerRadius: 5).fill(Color.init(red: 0.66, green: 0.66, blue: 0.99)).frame(width: width / 1.2, height: (height / CGFloat(10)) * 1.5, alignment: .center)
                    VStack {
                        Text(viewInt != 4 ? (viewInt == 0 ? ("Spent") : ( "Earned")) : ("Transfered")
                                + " this " + timeFilter).font(.title3).foregroundColor(.black).textCase(.uppercase)
                        
                        Text("$" + String(format:  "%.2f", abs(filteredData(exp: expenseList) .map({$0.value}).reduce(0, +)))).foregroundColor(.black).font(.largeTitle).fontWeight(.heavy)
                    }
                }
                ScrollView(.vertical) {
                    ForEach (chosenList, id: \.self) { c in
                        let curArr = filteredData(exp: expenseList, cat: c)
                        VStack {
                            if (viewInt != 4) {
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
                                                            String(format: "%.2f", abs(curArr.map({$0.value}).reduce(0, +)))).foregroundColor(.black).fontWeight(.medium)
                                                    Image(systemName: "chevron.right")
                                                }
                                            }.frame(width: width / 1.4, height: height / 9, alignment: .center)
                                        }
                                        Spacer()
                                    }
                                }
                            } else {
                                ExpenseListByCategory(category: c, expenses: curArr, width: width, height: height, tempAccounts: tempAccounts, tempCategories: tempCategories, tempIncome: tempIncome)
                            }
                            
                        }
                    }.frame(height: height, alignment: .topLeading)
                }
            }
        }
        //    }
        
        
    }
    
    
    func filteredData(exp: [Transaction], cat: String = "") -> [Transaction] {
        var initial : [Transaction] = []
        var temp : [Transaction] = []
        let date1 = Date()
        
        if (cat == "" && exp[0].category != "Transfer") {
            initial = exp.filter({($0.category != "Transfer" && $0.incomeType == "") || ($0.incomeType != "Transfer" && $0.category == "")})
           
            
        } else if (cat == "" && exp[0].category == "Transfer") {
            initial = exp
        }
        
        if (cat != "" && (self.viewInt == 1 || self.viewInt == 2)) {
            initial = exp.filter({$0.incomeType == cat})
        }
        
        if (cat != "" && (self.viewInt <= 1 || self.viewInt >= 3)) {
            initial += exp.filter({$0.category == cat})
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
       
        return temp
        
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
        //ScrollView {
            VStack(spacing: 0) {
                category != "Transfer" ?
                    Text("Transactions for \n" + category).font(.title2).padding(15).textCase(.uppercase).foregroundColor(.black).multilineTextAlignment(.center) : nil
                ForEach(expenses, id: \.self) { i in
                    showItems(exp: i, width: width, height: height, tempAccounts: tempAccounts, tempCategories: tempCategories, tempIncome: tempIncome)
                }
                Spacer()
          //  }
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
                            RoundedRectangle(cornerRadius: 5).fill(Color.init(red: 0.6196, green: 0.3647, blue: 0.5451)).frame(width: width / 1.1, height: height / 10, alignment: .center)

            HStack {
                Button(action: {self.clicked.toggle()}) {
                    Text(exp.name).foregroundColor(.white)
                    Spacer()
                    Text("$" + String(format: "%.2f", abs(exp.value))).foregroundColor(.white)
                    Image(systemName: "chevron.right")
                }
            }.frame(width: width / 1.4, height: height / 9, alignment: .center)
            
        }.popover(isPresented: $clicked) {
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
                  //  CurrencyTextField("Amount", value: $.value, alwaysShowFractions: false, numberOfDecimalPlaces: 2, currencySymbol: "US$").font(.largeTitle).multilineTextAlignment(TextAlignment.center)
                    TextField(String(abs(exp.value)), value: $exp.value, formatter: NumberFormatter()).border(Color.black).padding(5)
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
                        ref.child("income").child(exp.id).setValue(["account": exp.account, "category": exp.category, "date": exp.date , "incomeType": exp.incomeType, "name": exp.name, "value": Double(abs(exp.value))]) :  ref.child("expenditures").child(exp.id).setValue(["account": exp.account, "category": exp.category, "date": exp.date, "name": exp.name, "value": Double(-abs(exp.value))])
                    self.clicked.toggle()
                }) {
                    ZStack {
                        Text("Submit").font(.title2)
                    }
                }
            }
        }.frame(width: width / 1.2, height: height / 9, alignment: .center).onAppear(perform: {exp.value = abs(exp.value)})
    }
}

