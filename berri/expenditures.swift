
import Foundation
import SwiftUI
import Firebase
import SwiftUIKit

struct Expenditures: View {
    //@State var tempAccounts = [String]()
    //@State var tempCategories = [String]()
    // @State var tempIncome = [String]()
    @State var expenseList = [MTransaction]()
    
    //@State var expenses : [MTransaction]
    @State var timeFilter = "MONTH"
    // @State var reconList : [MTransaction]
    @State var curView = ["All Expenditures (E)", "All Income (P+I)", "True Income (I)", "Payback Only", "Transfer", "Reconed Expenses (E-P)"]
    @State var viewInt = 0
    // @State var incomeList : [MTransaction]
    @State var width: CGFloat
    @State var height: CGFloat
    
    @ObservedObject var fbHandler = FirebaseHandler()
    
    
    @State var chosenList = [String]()
    
    let times = ["DAY", "WEEK", "MONTH", "YEAR", "TOTAL"]
    
    var body: some View {
        //        NavigationView {
        VStack(spacing: 10) {
            HStack {
                Menu {
                    Button(action: {
                        self.expenseList = fbHandler.expenseList
                        self.viewInt = 0
                        self.chosenList = fbHandler.tempCategories
                        
                    }) {
                        Text(curView[0])
                    }
                    Button(action: {
                        self.expenseList = fbHandler.reconList
                        self.viewInt = 5
                        self.chosenList = fbHandler.tempCategories
                        // print("Hi recon 1: ", self.reconList.map({$0.name}))
                        
                    }) {
                        Text(curView[5])
                    }
                    Button(action: {
                        self.expenseList = fbHandler.reconList.filter({$0.isIncome == true}) +  fbHandler.incomeList
                        self.viewInt = 1
                        self.chosenList = fbHandler.tempCategories + fbHandler.tempIncome
                        //   print("Hi recon 2 : ",  self.reconList.map({$0.name}))
                        
                    }) {
                        Text(curView[1])
                    }
                    Button(action: {
                        self.expenseList = fbHandler.incomeList
                        self.viewInt = 2
                        self.chosenList = fbHandler.tempIncome
                    }) {
                        Text(curView[2])
                    }
                    Button(action: {
                        self.expenseList = fbHandler.reconList.filter({$0.isIncome == true})
                        self.viewInt = 3
                        self.chosenList = fbHandler.tempCategories
                        //   print("Hi recon income only: ",  self.reconList.map({$0.name}))
                        
                    }) {
                        Text(curView[3])
                    }
                    Button(action: {
                        self.expenseList = fbHandler.expenseList.filter({$0.category == "Transfer"})
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
                    Button (action: {
                        self.timeFilter = t
                        self.refreshData()
                    }) {
                        (t != timeFilter) ? Text(t).font(.title3).foregroundColor(.black) : Text(t).underline().font(.title3).foregroundColor(.black)
                    }
                }
            }
            
            
            VStack(spacing: 5) {
                ZStack {
                    RoundedRectangle(cornerRadius: 5).fill(Color("ExtraColor")).frame(width: width / 1.2, height: (height / CGFloat(10)) * 1.5, alignment: .center)
                    VStack {
                        Text(viewInt != 4 ? ((viewInt == 0 || viewInt == 5) ? ("Spent") : ( "Earned")) : ("Transfered")
                                + " this " + timeFilter).font(.title3).foregroundColor(.white).textCase(.uppercase)
                        
                        Text("$" + String(format:  "%.2f", abs(filteredData(exp: expenseList) .map({$0.value}).reduce(0, +)))).foregroundColor(.white).font(.largeTitle).fontWeight(.heavy)
                    }
                }
                ScrollView(.vertical) {
                    ForEach (chosenList, id: \.self) { c in
                        let curArr = filteredData(exp: expenseList, cat: c)
                        VStack {
                            if (viewInt != 4) {
                                HStack {
                                    
                                    NavigationLink(destination: ExpenseListByCategory(category: c, expenses: curArr, width: width, height: height, fbHandler: fbHandler)) {
                                        
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
                            } else {
                                ExpenseListByCategory(category: c, expenses: curArr, width: width, height: height, fbHandler: fbHandler)
                            }
                            
                        }
                    }.frame(height: height, alignment: .topLeading)
                }.onAppear(perform: refreshData)
            }.onAppear(perform: refreshData)
        }
    }
    
    func refreshData() {
        if (self.viewInt == 0) {
            self.expenseList = self.fbHandler.expenseList
        } else if (self.viewInt == 5) {
            self.expenseList = self.fbHandler.reconList
        } else if (self.viewInt == 2) {
            self.expenseList = self.fbHandler.incomeList
        } else if (self.viewInt == 3) {
            self.expenseList = self.fbHandler.reconList.filter({$0.isIncome == true})
        } else if (self.viewInt == 4) {
            self.expenseList = self.fbHandler.expenseList.filter({$0.category == "Transfer"})
        } else if (self.viewInt == 1) {
            self.expenseList = self.fbHandler.reconList.filter({$0.isIncome == true}) +  self.fbHandler.incomeList
        }
    }
    
    
    func filteredData(exp: [MTransaction], cat: String = "") -> [MTransaction] {
        var initial : [MTransaction] = []
        var temp : [MTransaction] = []
        let date1 = Date()
        
        if exp.count == 0 {
            return initial
        }
        
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
        return temp.sorted(by: {$0.convDate > $1.convDate})
        
    }
    
}

struct ExpenseListByCategory: View {
    @State var category: String
    @State var expenses: [MTransaction]
    @State var width: CGFloat
    @State var height: CGFloat
    
    @ObservedObject var fbHandler : FirebaseHandler
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                category != "Transfer" ?
                    Text("Transactions for \n" + category).font(.title2).padding(15).textCase(.uppercase).foregroundColor(.black).multilineTextAlignment(.center) : nil
                ForEach(expenses, id: \.self) { i in
                    showItems(exp: i, width: width, height: height, fbHandler: fbHandler)
                }
                Spacer()
                //  }
            }.navigationBarHidden(false)
        }
    }
}

struct showItems: View {
    @ObservedObject var exp: MTransaction
    @State var clicked: Bool = false
    @State var editChoice: Bool = false
    @State var width: CGFloat
    @State var height: CGFloat
    
    
    @ObservedObject var fbHandler : FirebaseHandler
    
    @State var value: Double! = 0.0
    
    
    static let itemDateFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter
    }()
    
    var body: some View {
        
        ZStack {
            exp.isIncome ? RoundedRectangle(cornerRadius: 5).fill(Color("IncomeColor")).frame(width: width / 1.1, height: height / 10, alignment: .center) :
                RoundedRectangle(cornerRadius: 5).fill(Color("BoxColor")).frame(width: width / 1.1, height: height / 10, alignment: .center)
            
            HStack {
                Button(action: {self.clicked.toggle()
                    
                }) {
                    Text(exp.name).foregroundColor(.black)
                    Spacer()
                    Text("$" + String(format: "%.2f", abs(exp.value))).foregroundColor(.black)
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
                    
                    CurrencyTextField("Amount", value: self.$value, alwaysShowFractions: false, numberOfDecimalPlaces: 2, currencySymbol: "US$").font(.largeTitle).multilineTextAlignment(TextAlignment.center)
                    
                }.frame(width: width/1.2)
                HStack {
                    Text("Account of Transaction: ").fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    Spacer()
                    Picker(exp.account, selection: $exp.account) {
                        ForEach(fbHandler.tempAccount, id: \.self) {
                            Text($0)
                        }
                    }.pickerStyle(MenuPickerStyle()).frame(minWidth: 0, maxWidth: width / 2)
                    
                }.frame(width: width/1.2)
                HStack {
                    Text("Category of Transaction: ").fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    Spacer()
                    Picker(exp.category, selection: $exp.category) {
                        exp.category == "" ? Text(exp.category) : nil
                        ForEach(fbHandler.tempCategories, id: \.self) {
                            Text($0)
                        }
                    }.pickerStyle(MenuPickerStyle()).frame(minWidth: 0, maxWidth: width / 2)
                }.frame(width: width/1.2)
                exp.isIncome ? HStack {
                    Text("Income Type of Transaction: ").fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    Spacer()
                    Picker(exp.incomeType, selection: $exp.incomeType) {
                        exp.incomeType == "" ? Text(exp.incomeType) : nil
                        ForEach(fbHandler.tempIncome, id: \.self) {
                            Text($0)
                        }
                    }.pickerStyle(MenuPickerStyle())
                }.frame(width: width/1.2) : nil
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        let ref = Database.database().reference()
                        exp.isIncome ? ref.child("income").child(exp.id).removeValue() : ref.child("expenditures").child(exp.id).removeValue()
                        self.clicked.toggle()
                        fbHandler.loadData()
                    }) {
                        ZStack {
                            Text("Delete").font(.title2)
                        }
                    }
                    Spacer()
                    Button(action: {self.clicked.toggle()}) {
                        Text("Close").font(.title2)
                    }
                    Spacer()
                    Button(action: {
                        let ref = Database.database().reference().child(Auth.auth().currentUser!.uid)
                        
                        exp.date = showItems.itemDateFormat.string(from: exp.convDate)
                        print("is submitting...")
                        print(exp.isIncome, exp.id)
                        exp.isIncome ?
                            ref.child("income").child(exp.id).setValue(["account": exp.account, "category": exp.category, "date": exp.date , "incomeType": exp.incomeType, "name": exp.name, "value": Double(abs(value))]) :
                            ref.child("expenditures").child(exp.id).setValue(["account": exp.account, "category": exp.category, "date": exp.date, "name": exp.name, "value": Double(-abs(value))])
                        self.clicked.toggle()
                        fbHandler.loadData()
                    }) {
                        ZStack {
                            Text("Submit").font(.title2)
                        }
                    }
                    Spacer()
                    
                }
            }
            
        }.frame(width: width / 1.2, height: height / 9, alignment: .center).onAppear(perform: {self.value = abs(exp.value)})
    }
}

