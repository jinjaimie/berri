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
            TextField("Cost of Meal", value: $cost, formatter: NumberFormatter()).padding(5).border(Color.black).frame(width: width/1.2, height: height/4).textFieldStyle(RoundedBorderTextFieldStyle()).padding(5)
            Text("Choose Tip Amount Below")
            Picker("Tip Amount", selection: $text2) {
                ForEach(tipOptions, id: \.self) {
                    Text($0)
                }
            }.pickerStyle(SegmentedPickerStyle()).frame(width: width/1.1)

            Text("You should tip: ")
            Text(String(format: "%.2f", cost * (Double(text2)!/100)))
            
        }
    }
}
