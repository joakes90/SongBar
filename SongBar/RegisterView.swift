//
//  SwiftUIView.swift
//  SongBar
//
//  Created by Justin Oakes on 3/24/22.
//  Copyright © 2022 joakes. All rights reserved.
//

import SwiftUI

struct RegisterView: View {
    @State var email = ""
    @State var license = ""
    @State var isRegistered = false
    @State var isValid = false

    var body: some View {
        VStack {
            Form {
                if !isRegistered {
                    Section(header: Text("Registration")
                        .fontWeight(.bold)) {
                        TextField(LocalizedStringKey(stringLiteral: "Email:"),
                                  text: $email)
                        .font(.callout)
                        TextField(LocalizedStringKey(stringLiteral: "License:"),
                                  text: $license)
                        .font(.callout)

                        Spacer()
                        HStack {
                            Spacer()
                            Button("Cancel") {
                                // dismiss
                            }
                            Button("Register") {
                                // register
                            }
                        }
                    }
                }
            }
            .padding()
            .frame(minWidth: 480.0,
                   idealWidth: 480.0,
                   minHeight: 150.0,
                   idealHeight: 150.0,
               alignment: .center)
        }
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
