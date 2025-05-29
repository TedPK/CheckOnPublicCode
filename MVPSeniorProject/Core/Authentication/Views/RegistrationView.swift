//
//  MVPRegistrationView.swift
//  SeniorProjectApp
//
//  Created by Family on 10/12/24.
//

import SwiftUI

struct RegistrationView: View {
    
    @StateObject var viewModel = RegistrationViewModel()
    
//    @State private var firstName: String = ""
    @State private var isEditingFirstName: Bool = false
    
//    @State private var lastName: String = ""
    @State private var isEditingLastName: Bool = false
    
//    @State private var email: String = ""
    @State private var isEditingEmail: Bool = false
    
//    @State private var password: String = ""
    @State private var isEditingPassword: Bool = false
    @FocusState private var isPasswordFieldFocused: Bool
    
    @State private var passwordAgain: String = ""
    @State private var isEditingPasswordAgain: Bool = false
    @FocusState private var isPasswordAgainFieldFocused: Bool
    
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("Register")
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .foregroundStyle(Constants.navyBlue)
                        .padding()
                    
                    Spacer()
                }
                
                //FIRST NAME-----------------------------------------------------------
                TextField("First name", text: $viewModel.firstName, onEditingChanged: { editing in
                    isEditingFirstName = editing
                })
                .padding(.bottom, 8)
                .overlay(
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(isEditingFirstName ? Constants.navyBlue : .gray),
                    alignment: .bottom
                )
                .padding(.horizontal)
                .padding(.bottom, 20)
                
                //LAST NAME-----------------------------------------------------------
                TextField("Last name", text: $viewModel.lastName, onEditingChanged: { editing in
                    isEditingLastName = editing
                })
                .padding(.bottom, 8)
                .overlay(
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(isEditingLastName ? Constants.navyBlue : .gray),
                    alignment: .bottom
                )
                .padding(.horizontal)
                .padding(.bottom, 20)
                
                //EMAIL-----------------------------------------------------------
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
                .padding(.bottom, 20)
                
                //PASSWORD-----------------------------------------------------------
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
                    .padding(.bottom, 20)
                
                //PASSWORD AGAIN-----------------------------------------------------------
                SecureField("Password again", text: $passwordAgain)
                    .focused($isPasswordAgainFieldFocused)
                    .onChange(of: isPasswordAgainFieldFocused, initial: isPasswordAgainFieldFocused) { _, isFocused in
                        isEditingPasswordAgain = isFocused
                    }
                    .padding(.bottom, 8)
                    .overlay(
                        Rectangle()
                            .frame(height: 2)
                            .foregroundColor(isEditingPasswordAgain ? Constants.navyBlue : .gray),
                        alignment: .bottom
                    )
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                
                //Signup Button-----------------------------------------------------------
                NavigationLink(destination: ParentMainView()) {
                    Button {
                        Task { try await viewModel.createUser() }
                    } label: {
                        Text("Sign up")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .frame(width: 360, height: 50)
                            .background(Constants.navyBlue)
                            .cornerRadius(25)
                    }
                }
                NavigationLink {
                    LoginView()
                        .navigationBarBackButtonHidden()
                } label: {
                    Text("Have an account? Log in")
                        .fontWeight(.semibold)
                        .foregroundStyle(Constants.navyBlue)
                }
            }
        }
    }
}


#Preview {
    RegistrationView()
}
