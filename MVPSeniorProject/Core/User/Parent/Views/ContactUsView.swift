//
//  ContactUsView.swift
//  MVPSeniorProject
//
//  Created by Family on 2/13/25.
//

import SwiftUI

struct ContactUsView: View {
    @State private var message: String = ""
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter your message...", text: $message)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(height: 50) // Adjust the height of the text field
                
                Spacer()
            }
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Send") {
                    print("Send Message")
                    dismiss()
                }
            )
            .navigationBarTitleDisplayMode(.inline)
            .padding()
        }
    }
}

#Preview {
    ContactUsView()
}
