//
//  SwiftUIView.swift
//  SongBar
//
//  Created by Justin Oakes on 3/24/22.
//  Copyright © 2022 joakes. All rights reserved.
//

import SwiftUI
import Combine
import Firebase

struct RegisterView: View {
    @ObservedObject var defaultsController = DefaultsController.shared
    @State var processing = false
    @State var isValid = false

    private func register() {
        processing = true
        defaultsController.setEmail(newValue: defaultsController.email)
        defaultsController.setLicense(newValue: defaultsController.license)
        if defaultsController.licenseMatches() {
            defaultsController.isPremium = true
            Analytics.logEvent(event: .registerApp, parameters: ["license": defaultsController.license])
            NSApp.keyWindow?.close()
        }
    }

    var body: some View {
        VStack {
            Form {
                Section(header: Text("Registration")
                    .fontWeight(.bold)) {
                        TextField("Email:",
                                  text: $defaultsController.email)
                        .font(.callout)
                        .onChange(of: defaultsController.email, perform: { value in
                            defaultsController.email = String(
                                value
                                    .trimmingCharacters(in: .whitespacesAndNewlines)
                                    .lowercased()
                            )
                            isValid = defaultsController.licenseMatches()
                        })
                        TextField("License:",
                                  text: $defaultsController.license)
                        .font(.callout)
                        .onChange(of: defaultsController.license, perform: { value in
                            defaultsController.license = String(
                                value
                                    .replacingOccurrences(of: "-", with: "")
                                    .uppercased()
                                    .enumerated()
                                    .map {
                                        $0.isMultiple(of: 4) && $0 != 0 ? "-\($1)" : String($1)
                                    }
                                    .joined()
                                    .prefix(19)
                            )

                            isValid = defaultsController.licenseMatches()
                        })

                        Spacer()
                        HStack {
                            Spacer()
                            if !processing {
                                Button("Cancel") {
                                    NSApp.keyWindow?.close()
                                }
                                Button("Register") {
                                    register()
                                }
                                .disabled(!isValid)
                            } else {
                                ProgressView()
                                    .scaleEffect(0.5)
                            }
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
