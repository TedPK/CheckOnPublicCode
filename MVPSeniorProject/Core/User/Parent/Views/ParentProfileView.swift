//
//  ParentProfileView.swift
//  MVPSeniorProject
//
//  Created by Family on 10/19/24.
//


import SwiftUI

struct ParentProfileView: View {
    
    @StateObject private var viewModel = ProfileViewModel()
    @State private var navigateToLogin = false
    @State private var navigateToJoinCreateCircle = false
    
    @State private var showPasswordSheet = false
    @State private var password = ""
    @State private var isDeleting = false

    var body: some View {
        NavigationStack {
            Form {
                Section("First Name") {
                    Text("\(viewModel.firstName)")
                }
                Section("Last Name") {
                    Text("\(viewModel.lastName)")
                }
                Section("Email") {
                    Text("\(viewModel.email)")
                }
                
                Section("App") {
                    Link("Privacy Policy", destination: URL(string: "https://docs.google.com/document/d/1MTLLWLYD2zzZQJdgugm7v1Sp-KrZSNv6L7-xJVfNXwM/edit?tab=t.0")!)
                }
                
                Button {
                    AuthService.shared.signOut()
                    navigateToLogin = true
                } label: {
                    Text("Sign out")
                }
                
                Button {
                    Task {
                        await CircleService.shared.parentCloseCircle()
                        navigateToJoinCreateCircle = true
                    }
                } label: {
                    Text("Close Circle")
                        .foregroundStyle(.yellow)
                }
                
                Button {
                    showPasswordSheet = true
                } label: {
                    Text("Delete Account")
                        .foregroundStyle(.red)
                }
            }
            .navigationTitle("Profile")
            .navigationDestination(isPresented: $navigateToLogin) {
                SignInView()
                    .navigationBarBackButtonHidden()
            }
            .navigationDestination(isPresented: $navigateToJoinCreateCircle) {
                JoinCreateCircleView()
                    .navigationBarBackButtonHidden()
            }
            .sheet(isPresented: $showPasswordSheet) {
                VStack(spacing: 20) {
                    Text("Please sign out first, then back in before confirming Account Deletion")
                        .font(.title2)
                        .bold()
                    
                    if isDeleting {
                        ProgressView()
                    } else {
                        Button("Delete Account") {
                            Task {
                                isDeleting = true
                                await AuthService.shared.parentDeleteAccount()
                                isDeleting = false
                                navigateToLogin = true
                            }
                        }
                        .foregroundColor(.red)
                    }
                    
                    Button("Cancel") {
                        showPasswordSheet = false

                    }
                }
                .padding()
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchUserData()
            }
        }
    }
}


#Preview {
    ChildProfileView()
}
