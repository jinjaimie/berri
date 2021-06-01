//
//  FormView.swift
//  berri
//
//  Created by stlp on 5/30/21.
//

import SwiftUI

struct FormView: View {
    var body: some View {
        GeometryReader { geom in
            VStack (spacing: 10) {
                HStack {
                    Text("Add new").font(.largeTitle).fontWeight(.bold)
                    Spacer()
                }
                Spacer()
                HStack {
                    Text("Name")
                    Spacer()
                }.frame(width: geom.size.width * 0.8)
                HStack {
                    Text("Initial Amount")
                    Spacer()
                }.frame(width: geom.size.width * 0.8)
                Spacer()
                Spacer()
                HStack {
                    Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                        Text("Save")
                    }).padding().font(.custom("button", size: 20))
                    Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                        Text("Cancel")
                    }).foregroundColor(.secondary).padding().font(.custom("button", size: 20))
                }
            }
        }
    }
}

struct FormView_Previews: PreviewProvider {
    static var previews: some View {
        FormView()
    }
}
