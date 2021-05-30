////
////  expenditures.swift
////  berri
////
////  Created by stlp on 5/29/21.
////
//
//import Foundation
//import SwiftUI
//import Firebase
//
//struct Expenditures: View {
//    var body: some View {
//        // let tempAccounts = ["Savings", "Checking", "Total"]
//        let tempCategories = ["Dining Out", "Rent/Utilities", "Textbook/Supplies", "Groceries", "Entertainment", "Transportation", "Desserts and Treats", "House Items", "Other"]
//        GeometryReader { m in
//            VStack {
//                ZStack {
//                    RoundedRectangle(cornerRadius: 5).fill(Color.init(red: 0.99, green: 0.66, blue: 0.66)).frame(width: m.size.width / 1.2, height: (m.size.height / CGFloat((tempCategories.count + 3))) * 3, alignment: .center)
//                    VStack {
//                        Text("Spent").font(.title).foregroundColor(.black)
//                        Text("$260.67").foregroundColor(.black)
//                    }
//                }
//                VStack {
//                    ForEach (tempCategories, id: \.self) { c in
//                        Categories(category: c, num: tempCategories.count)
//                    }
//                }
//            }
//        }
//    }
//}
//
//struct Categories: View {
//    @State var category: String
//    @State var num: Int
//    var body: some View {
//        GeometryReader { m in
//            HStack {
//                Spacer()
//            ZStack {
//                RoundedRectangle(cornerRadius: 5).fill(Color.init(red: 0.66, green: 0.99, blue: 0.66)).frame(width: m.size.width / 1.2, height: m.size.height, alignment: .center)
//                Text(category).font(.title).foregroundColor(.black)
//            }
//        }
//            
//        }
//    }
//}
