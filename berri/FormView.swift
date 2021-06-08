//
//  FormView.swift
//  berri
//
//  Created by stlp on 5/30/21.
//

import SwiftUI
import Firebase

struct AccountForm: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var name:String = ""
    @State var amount:String = ""
    @State var showAlert = false
    @State var alertType = ""
    @State var ref: DatabaseReference! = (Auth.auth().currentUser == nil) ? Database.database().reference() : Database.database().reference().child(Auth.auth().currentUser!.uid)
    
    var body: some View {
        GeometryReader { geom in
            ScrollView {
                VStack (spacing: 30) {
                    HStack {
                        Text("New account").font(.largeTitle).fontWeight(.bold)
                        Spacer()
                    }.padding(.bottom, geom.size.height*0.02)
                    HStack {
                        TextField("Enter Name", text: $name).padding().border(Color.gray).cornerRadius(8.0)
                        Spacer()
                    }
                    HStack {
                        TextField("Enter Balance", text: $amount).padding().border(Color.gray).cornerRadius(8.0)
                        Spacer()
                    }
                    Spacer()
                    HStack {
                        Button(action: {
                            let initial = Double(amount)
                            self.ref.child("accounts/\(name)/").getData { (error, snapshot) in
                                if snapshot.exists() {
                                    showAlert = true
                                    alertType = "existingAcct"
                                } else if (initial == nil) {
                                    showAlert = true
                                    alertType = "invalidAmount"
                                } else if (error == nil) {
                                    self.ref.child("accounts").child(name).setValue(["amount": initial]) { (err, ref) in
                                        if err != nil {
                                            showAlert = true
                                            alertType = "error"
                                        } else {
                                            self.presentationMode.wrappedValue.dismiss()
                                        }
                                    }
                                    
                                    
                                } else {
                                    print("Error")
                                }
                            }
                        }, label: {
                            Text("Save")
                        }).disabled(name.isEmpty || amount.isEmpty)
                        .alert(isPresented: $showAlert) {
                            switch alertType {
                                case "existingAcct":
                                    return Alert(
                                        title: Text("Error"),
                                        message: Text("This account already exists"),
                                        dismissButton: .default(Text("Okay"))
                                    )
                                case "invalidAmount":
                                    return Alert(
                                        title: Text("Input Invalid"),
                                        message: Text("Your initial balance can only be a numerical value"),
                                        dismissButton: .default(Text("Okay"))
                                    )
                                default:
                                    return Alert(
                                        title: Text("Unknown Error"),
                                        message: Text("Try again later"),
                                        dismissButton: .default(Text("Okay"))
                                    )
                            }
                        }
                        .padding(.horizontal, geom.size.width*0.1).font(.custom("button", size: 17))
                        Button(action: {
                                self.presentationMode.wrappedValue.dismiss()
                        }, label: {
                            Text("Cancel")
                        }).foregroundColor(.secondary).padding(.horizontal, geom.size.width*0.1).font(.custom("button", size: 17))
                    }
                }.padding(.horizontal, geom.size.width*0.1)
            }
        }.onAppear {
            ref = Database.database().reference().child(Auth.auth().currentUser!.uid)
        }
    }
}

struct CategoryForm: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var name:String = ""
    @State var showAlert = false
    @State var ref: DatabaseReference! = (Auth.auth().currentUser == nil) ? Database.database().reference() : Database.database().reference().child(Auth.auth().currentUser!.uid)
    
    var body: some View {
        GeometryReader { geom in
            ScrollView {
                VStack (spacing: 30) {
                    HStack {
                        Text("New category").font(.largeTitle).fontWeight(.bold)
                        Spacer()
                    }.padding(.bottom, geom.size.height*0.02)
                    HStack {
                        TextField("Enter Category", text: $name).padding().border(Color.gray).cornerRadius(8.0)
                        Spacer()
                    }
                    Spacer()
                    HStack {
                        Button(action: {
                            self.ref.child("categories/").getData { (error, snapshot) in
                                var array:[String] = []
                                var found = false
                                for child in snapshot.children {
                                    let snap = child as! DataSnapshot
                                    let val = snap.value as! String
                                    if (val == name) {
                                        showAlert = true
                                        found = true
                                    } else {
                                        array.append(val)
                                    }
                                }
                                if (found == false) {
                                    array.append(name)
                                    self.ref.child("categories").setValue(array) { (err, ref) in
                                        self.presentationMode.wrappedValue.dismiss()
                                    }
                                }
                            }
                        }, label: {
                            Text("Save")
                        }).disabled(name.isEmpty)
                        .alert(isPresented: $showAlert) {
                            Alert(
                                title: Text("Error"),
                                message: Text("This category already exists"),
                                dismissButton: .default(Text("Okay"))
                            )
                        }
                        .padding(.horizontal, geom.size.width*0.1).font(.custom("button", size: 17))
                        Button(action: {
                                self.presentationMode.wrappedValue.dismiss()
                        }, label: {
                            Text("Cancel")
                        }).foregroundColor(.secondary).padding(.horizontal, geom.size.width*0.1).font(.custom("button", size: 17))
                    }
                }.padding(geom.size.width*0.1)
            }
        }.onAppear {
            ref = Database.database().reference().child(Auth.auth().currentUser!.uid)
        }
    }
}

struct FormView_Previews: PreviewProvider {
    static var previews: some View {
        AccountForm()
    }
}
