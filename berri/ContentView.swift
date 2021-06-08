//
//  ContentView.swift
//  berri
//
//  Created by Saatvik Arya on 5/26/21.
//

import SwiftUI
import Firebase

struct ContentView: View {
    
    let main:UIColor = UIColor(Color("MainColor"))
    let accent:UIColor = UIColor(Color("AccentColor"))
    let extraAccent = UIColor(Color("ExtraColor"))
    @State var navBarHidden: Bool = true
    //UIScrollView.appearance().backgroundColor = UIColor.red
    
    @StateObject var firebaseHandler = FirebaseHandler()


//    var backgroundColor: UIColor? = UIColor(red: 0.937, green: 0.824, blue: 0.827, alpha: 1)
//        var titleColor: Color = Color(red: 0.64, green: 0.36, blue: 0.25)

    @State var presentAuth = (Auth.auth().currentUser == nil)
    
    var backgroundColor: UIColor? = UIColor(red: 0.937, green: 0.824, blue: 0.827, alpha: 1)
        var titleColor: Color = Color(red: 0.64, green: 0.36, blue: 0.25)
    let coloredAppearance = UINavigationBarAppearance()
   
    init() {
            // 1.
           //  UINavigationBar.appearance().backgroundColor = main
        
       
            // 3.
          //  UINavigationBar.appearance().titleTextAttributes = [
             //   .font : UIFont(name: "HelveticaNeue-Thin")!]
    
    }
    
    var body: some View {
        GeometryReader { m in
        NavigationView {
            TabView {
                ZStack {
                    AccountView(handler: firebaseHandler)
                }.tabItem { Label("Account", systemImage: "person.fill") }
                .tag(1)
                
                ZStack {
                    Expenditures(tempAccounts: firebaseHandler.tempAccount, tempCategories: firebaseHandler.tempCategories, tempIncome: firebaseHandler.tempIncome, expenseList: firebaseHandler.expenseList, expenses: firebaseHandler.expenseList, reconList: firebaseHandler.reconList, incomeList: firebaseHandler.incomeList, width: m.size.width, height: m.size.height, fbHandler: firebaseHandler, chosenList : firebaseHandler.tempCategories)
                }.tabItem { Label("Expenses", systemImage: "dollarsign.circle.fill").foregroundColor(.white) }
                .tag(2)
                
                ZStack {
                    ConfirmAccount(width: m.size.width, height: m.size.height, accounts: firebaseHandler.tempAccount, categories: firebaseHandler.tempCategories, incomes: firebaseHandler.tempIncome)
                }.tabItem {
                    Label("Add", systemImage: "plus").foregroundColor(.black)
                }.tag(3)

                ZStack {
                    TipCalculator(width: m.size.width, height: m.size.height)
                }.tabItem { Label("Tips", systemImage: "candybarphone") }
                .tag(4)
                ZStack {
                    SettingView(presentAuth: $presentAuth)
                }.tabItem { Label("Settings", systemImage: "gear") }
                .tag(4)

            }.accentColor(Color("ExtraColor")).onAppear(perform: firebaseHandler.authenticate)

        .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Spacer()
                    Image("berri")
                        Spacer()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {
                        firebaseHandler.loadData()
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .onAppear() {
                UITabBar.appearance().barTintColor = main
                UITabBar.appearance().unselectedItemTintColor = accent
            }

            .fullScreenCover(isPresented: $presentAuth) {
                AuthView()
            }
        }.navigationViewStyle(StackNavigationViewStyle()).navigationBarHidden(false)
        .navigationBarTitle(Text("Home"))
        .edgesIgnoringSafeArea([.top, .bottom])

    }
}
}

struct SettingView: View {
    @Binding var presentAuth: Bool
    
    var body: some View {
        VStack (spacing: 5) {
            NavigationLink(
                destination: AccountForm()) {
                Text("Add an account").padding()
            }
            NavigationLink(
                destination: CategoryForm(t: "expenseTypes")) {
                Text("Add an expense type").padding()
            }
            NavigationLink(
                destination: CategoryForm(t: "incomeTypes")) {
                Text("Add an income type").padding()
            }
            Button {
                try! Auth.auth().signOut()
                presentAuth = true
                print(Auth.auth().currentUser)
            } label: {
                Text("Sign Out").padding()
            }

        }
    }
    
}

class FirebaseHandler: ObservableObject {
    @Published var tempAccounts = Dictionary<String, Double>()
    @Published var tempAccount = [String]()
    @Published var tempCategories = [String]()
    @Published var expenseList = [MTransaction]()
    @Published var incomeList = [MTransaction]()
    @Published var reconList = [MTransaction]()
    @Published var tempIncome = [String]()
    
    func authenticate() {
        Auth.auth().addStateDidChangeListener { auth, user in
            if let _ = user {
                self.loadData()
            } else {
                self.tempAccounts = Dictionary<String, Double>()
                self.tempAccount = [String]()
                self.tempCategories = [String]()
                self.expenseList = [MTransaction]()
                self.incomeList = [MTransaction]()
                self.reconList = [MTransaction]()
                self.tempIncome = [String]()
            }
        }
    }
    
    func loadData() {
        let userID = Auth.auth().currentUser!.uid
        reconList = []
        let ref = Database.database().reference()

        ref.child(userID).child("expenseTypes").observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                self.tempCategories = self.makeItems(from: snapshot).sorted(by: {$0 < $1})
            }
        }
        ref.child(userID).child("incomeTypes").observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                self.tempIncome = self.makeItems(from: snapshot).sorted(by: {$0 < $1})
            }
        }
        ref.child(userID).child("expenditures").observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                let temp = self.createTransactions(from: snapshot, isIncome: false)
                self.expenseList = temp.sorted(by: {$0.convDate > $1.convDate})
                // print("Expenses: ", temp.map({$0.name}))
            }
        }
        ref.child(userID).child("income").observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                let temp = self.createTransactions(from: snapshot, isIncome: true)
                self.incomeList = temp.sorted(by: {$0.convDate > $1.convDate})
                // print("Incomes: ", temp.map({$0.name}))
            }
        }


        ref.child(userID).child("accounts").observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                let temp = self.makeAccounts(from: snapshot)
                self.tempAccount = Array(temp.keys).sorted(by: {$0 < $1})
                self.tempAccounts = temp
            }
     
        }
//        print("is called: ", self.expenseList.map({$0.name}))
//        print("is called income: ", self.incomeList.map({$0.name}))
//        print("is called recon: ", self.reconList.map({$0.name}))
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
    
    func makeAccounts(from snapshot: DataSnapshot) -> Dictionary<String, Double> {
        var accounts = Dictionary<String, Double>()
        if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
            for snap in snapshots {
//                if let postDictionary = snap.value as? Dictionary<String, AnyObject> {
//                    items[snap.key] = postDictionary["amount"] as? Double
                if let account = snap.value as? NSDictionary {
                    accounts[snap.key] = account["amount"] as? Double
                }
            }
        }
        return accounts
    }
    
    func createTransactions(from snapshot: DataSnapshot, isIncome: Bool) -> [MTransaction]  {
        var tempList = [MTransaction]()
        if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
            print(snapshots.count)
            for snap in snapshots {
                if let postDictionary = snap.value as? Dictionary<String, AnyObject> {
                    let item = MTransaction(id: String(snap.key), account: postDictionary["account"] as! String, date: postDictionary["date"] as! String, name: postDictionary["name"] as! String, value: postDictionary["value"] as! Double, category: postDictionary["category"] as! String)
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MM/dd/yyyy"
                    item.convDate = dateFormatter.date(from: item.date)!
                    if (isIncome) {
                        item.isIncome = true
                        item.incomeType = postDictionary["incomeType"] as! String
                    }
                    if (item.category != "") {
                       // isIncome ? item.value = -(item.value) : nil
                        reconList.append(item)
                      //  print("did append", item.name)
                    }
                    if (isIncome && item.category == "" || !isIncome && item.category != "") {
                        tempList.append(item)
                    }
                }
            }
        }
        return tempList
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
      //  ConfirmAccount(width: CGFloat(360), height: CGFloat(800), accounts: ["Checking", "Savings", "Other", "Another"], categories: ["Test1", "Test2", "Test4", "Test5", "Test6"])
        
    }
}
