//
//  MVPViewModel.swift
//  SeniorProjectApp
//
//  Created by Family on 10/12/24.
//

import Foundation

import SwiftUI
import AuthenticationServices

class LoginViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var password = ""
    
    func login() async throws {
        try await AuthService.shared.login(withEmail: email, password: password)
    }
    
    func signInWithGoogle() async {
        await AuthService.shared.signInWithGoogle()
    }
    
    @MainActor func signInWithAppleRequest(request: ASAuthorizationAppleIDRequest) {
        AuthService.shared.signInWithAppleRequest(request: request)
    }

    func signInWithAppleCompletion(result: Result<ASAuthorization, Error>) async {
        await AuthService.shared.signInWithAppleCompletion(result: result)
    }
    
}
