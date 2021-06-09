//
//  Auth.swift
//  berri
//
//  Created by Saatvik Arya on 6/3/21.
//

import SwiftUI
import Firebase

struct AuthView: View {
    @State private var email = ""
    @State private var password = ""
    
    @StateObject var firebaseHandler = FirebaseHandler()
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        GeometryReader { m in
            NavigationView {
               
                VStack(spacing: 8) {
                    Image("berri")
                    HStack {
                        Text("Email       ")
                        TextField("Email", text: $email).keyboardType(.emailAddress).autocapitalization(.none).padding()
                    }
                    HStack {
                        Text("Password")
                        SecureField("Password", text: $password).padding()
                    }
                    
                    
                    HStack(spacing: 10) {
                        Button {
                            handleSignIn()
                        } label: {
                            Text("Sign In").bold()
                        }.padding()
                        Button {
                            handleSignUp()
                        } label: {
                            Text("Sign Up").bold()
                        }.padding()
                    }
                }.padding()
            }
        }
    }
    
    
    
    func handleSignIn() {
        
        Auth.auth().signIn(withEmail: email, password: password) { authResult, err in
            if err == nil {
                presentationMode.wrappedValue.dismiss()
            }
            
        }
    }
    
    func handleSignUp() {
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, err in
            if err == nil {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
}


