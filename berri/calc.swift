//
//  write.swift
//  berri
//
//  Created by stlp on 5/31/21.
//

import Foundation
import SwiftUI
import Firebase

struct TipCalculator : View {
    @State var cost : Double = 0.0
    @State var tipOptions: [String] = ["10", "15", "18", "20"]
    
    @State var text2 : String = "10"
    @State var text3 : String = "hi2"
    
    @State var width: CGFloat
    @State var height: CGFloat
    
    var body: some View {
        VStack {
            Text("Tip Calculator").font(.largeTitle).fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/).multilineTextAlignment(/*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/).foregroundColor(Color("AccentColor"))
            Spacer()
            Group {
                Text("Enter the cost of your meal:").fontWeight(.bold).foregroundColor(Color("AccentColor"))
                TextField("Cost of Meal", value: $cost, formatter: NumberFormatter()).border(Color.black).frame(width: width/1.2, height: 40).textFieldStyle(RoundedBorderTextFieldStyle()).padding(5)
            }
            Spacer()
            Group {
                Text("Choose tip amount:").fontWeight(.bold).foregroundColor(Color("AccentColor"))
                Picker("Tip Amount", selection: $text2) {
                    ForEach(tipOptions, id: \.self) {
                        Text($0)
                    }
                }.pickerStyle(SegmentedPickerStyle()).frame(width: width/1.1)
            }
            Spacer()
            Group {
                Text("You should tip: ").fontWeight(.bold).foregroundColor(Color("AccentColor"))
                Text(String(format: "%.2f", cost * (Double(text2)!/100)))
            }
            Spacer()
        }
    }
}
