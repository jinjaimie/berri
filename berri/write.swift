//
//  write.swift
//  berri
//
//  Created by stlp on 5/31/21.
//

import Foundation
import SwiftUI
import Firebase

struct WriteTest : View {
    @State var text1 : String = "hi"
    @State var text2 : String = "hi1"
    @State var text3 : String = "hi2"
    
    var body: some View {
        VStack {
            TextField("Enter 1", text: $text1)
            TextField("Enter 2", text: $text2)
            TextField("Enter 3", text: $text3)
            
            Button(action: {
                let ref = Database.database().reference().child(Auth.auth().currentUser!.uid)
                ref.child("test").child(String(Int.random(in: 6..<19428))).setValue(["username": text1, "user1": text2, "user3": text3])
            }) {
                Text("Submit").font(.title)
            }
        }
    }
}
