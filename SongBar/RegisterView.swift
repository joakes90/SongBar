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

    private func license(for string: String) -> String? {
        guard let data = string.data(using: .utf8)?.base64EncodedString() else { return nil }

        let subString = data
            .trimmingCharacters(in: .alphanumerics.inverted)
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .padding(toLength: 16, withPad: "0", startingAt: 0)
            .uppercased()
            .enumerated()
            .map { ($0.isMultiple(of: 4) && $0 != 0 ? "-\($1)" : String($1)) }
            .joined()
            .prefix(19)
        return String(subString)
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

                            isValid = license(for: email) == defaultsController.license
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

                            isValid = license(for: email) == defaultsController.license
                        })

                        Spacer()
                        HStack {
                            Spacer()
                            Button("Cancel") {
                                NSApp.keyWindow?.close()
                            }
                            Button("Register") {
                                register()
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
