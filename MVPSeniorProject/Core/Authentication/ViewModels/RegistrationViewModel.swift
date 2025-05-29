//
//  RegistrationViewModel.swift
//  MVPSeniorProject
//
//  Created by Family on 10/13/24.
//

import Foundation
import SwiftUI


class RegistrationViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var password = ""
    @Published var firstName = ""
    @Published var lastName = ""
    
    func createUser() async throws {
        try await AuthService.shared.createUser(withEmail: email, password: password, firstName: firstName, lastName: lastName)
    }
}
