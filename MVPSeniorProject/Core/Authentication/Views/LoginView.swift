//
//  MVPLoginScreen.swift
//  SeniorProjectApp
//
//  Created by Family on 10/12/24.
//

import SwiftUI

struct LoginView: View {
    
    @StateObject var viewModel = LoginViewModel()
    
    @State private var isEditingEmail: Bool = false
    
    @State private var isEditingPassword: Bool = false
    @FocusState private var isPasswordFieldFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("Log in")
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .foregroundStyle(Constants.navyBlue)
                        .padding()
                    
                    Spacer()
                }
                TextField("Email", text: $viewModel.email, onEditingChanged: { editing in
                    isEditingEmail = editing
                })
                .padding(.bottom, 8)
                .overlay(
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(isEditingEmail ? Constants.navyBlue : .gray),
                    alignment: .bottom
                )
                .padding(.horizontal)
                .padding(.bottom, 30)
                
                
                //Password--------------------------------------
                SecureField("Password", text: $viewModel.password)
                    .focused($isPasswordFieldFocused)
                    .onChange(of: isPasswordFieldFocused, initial: isPasswordFieldFocused) { _, isFocused in
                        isEditingPassword = isFocused
                    }
                    .padding(.bottom, 8)
                    .overlay(
                        Rectangle()
                            .frame(height: 2)
                            .foregroundColor(isEditingPassword ? Constants.navyBlue : .gray),
                        alignment: .bottom
                    )
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                
                
                Button {
                    Task { try await viewModel.login() }
                } label: {
                    Text("Log in")
                        .bold()
                        .foregroundStyle(Constants.navyBlue)
                        .overlay(Capsule().stroke(Constants.navyBlue, lineWidth: 5).frame(width: 360, height: 50))
                }
                .padding(.vertical)
                
                NavigationLink {
                    RegistrationView()
                        .navigationBarBackButtonHidden()
                } label: {
                    Text("Don't have an account? Register")
                        .fontWeight(.semibold)
                        .foregroundStyle(Constants.navyBlue)
                }
            }
        }
    }
}

#Preview {
    LoginView()
}
