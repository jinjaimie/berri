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
                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                    TextField("Password", text: $password)
                    
                    HStack(spacing: 10) {
                        Button("Sign In", action: handleSignIn)
                        Button("Sign Up", action: handleSignUp)
                    }
                    
                    
                }.padding()
                
            }
            
        }
        
    }
    
    
    
    func handleSignIn() {
        
        Auth.auth().signIn(withEmail: email, password: password) { authResult, err in
            print(authResult?.user)
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    func handleSignUp() {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, err in
            presentationMode.wrappedValue.dismiss()
        }
    }
    
}


