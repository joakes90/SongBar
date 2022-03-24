//
//  SwiftUIView.swift
//  SongBar
//
//  Created by Justin Oakes on 3/24/22.
//  Copyright © 2022 joakes. All rights reserved.
//

import SwiftUI
import Combine

struct RegisterView: View {
    @ObservedObject var defaultsController = DefaultsController.shared
    @State var email = ""
    @State var isValid = false

    private func register() {
        print("Set this up")
    }

    var body: some View {
        VStack {
            Form {
                Section(header: Text("Registration")
                    .fontWeight(.bold)) {
                        TextField("Email:",
                                  text: $email)
                        .font(.callout)
                        .onChange(of: email, perform: { value in
                            email = value
                                .trimmingCharacters(in: .whitespacesAndNewlines)
                                .lowercased()
                        })
                        TextField("License:",
                                  text: $defaultsController.license)
                        .font(.callout)
                        .onChange(of: defaultsController.license, perform: { value in
                            defaultsController.license = value.uppercased()
                        })

                        Spacer()
                        HStack {
                            Spacer()
                            Button("Cancel") {
                                NSApp.keyWindow?.close()
                            }
                            Button("Register") {
                                // register
                            }
                            .disabled(!isValid)
                        }
                    }
            }
            .disableAutocorrection(true)
            .onSubmit {
                register()
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