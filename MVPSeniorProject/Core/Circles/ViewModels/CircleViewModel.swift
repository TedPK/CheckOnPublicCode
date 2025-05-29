//
//  EnterCodeViewModel.swift
//  MVPSeniorProject
//
//  Created by Family on 12/4/24.
//

import Foundation
import FirebaseAuth

class CircleViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var enteredCode: String = ""
    @Published var codeCorrect: Bool = false
    @Published var currentJoinCode: String = ""
    
    @MainActor
    func createCircleTapped() async throws {
        isLoading = true
        errorMessage = nil
        do {
            try await CircleService.shared.createCircle() // Assuming createCircle logic is intact
        } catch {
            errorMessage = "Failed to create a circle: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    @MainActor
    func updateJoinCode() async {
        guard let codeExpiredStatus = await CircleService.shared.codeExpired() else {
            print("Unable to determine if the code has expired.")
            return
        }

        if codeExpiredStatus {
            // If the code has expired, generate a new code and set it
            print("Code has expired. Creating a new code.")
            await CircleService.shared.setNewCode() // This will set the new code on Firestore
            currentJoinCode = await CircleService.shared.fetchCurrentCode()! // Fetch the new code and set it
        } else {
            // If the code has not expired, fetch the current code
            print("Code is still valid. Fetching current code.")
            currentJoinCode = await CircleService.shared.fetchCurrentCode()!
        }
    }
    
    @MainActor
    func codeEntered() async {
        isLoading = true
        errorMessage = nil
        
        // Use a `do-catch` to catch potential errors in Firestore or network calls
        // Check if the code exists in Firestore
        let isValid = await CircleService.shared.checkCircleCodeExists(code: enteredCode)
        let circleRef = await CircleService.shared.getCircleRef(byCode: enteredCode)
        
        // Safely unwrap the circleId before calling addUserToCircle
        guard let circleRef = circleRef else {
            // If circleId is nil, handle the error (e.g., show an error message)
            errorMessage = "Circle ID not found. Please check the code and try again."
            isLoading = false
            return
        }

        do {
            try await CircleService.shared.addUserToCircle(circleRef: circleRef)
            // If successful, continue with your logic here (e.g., update UI, set state, etc.)
        } catch {
            // Handle the error (e.g., show an alert, log the error, etc.)
            print("Error adding user to circle: \(error.localizedDescription)")
            errorMessage = "Error adding user to circle. Please try again."
        }
        
        // Update the codeCorrect based on the result
        codeCorrect = isValid
        
        // If the code is invalid, show an error message
        if !isValid {
            errorMessage = "Invalid code. Please try again."
        }
        
        isLoading = false
    }
}
