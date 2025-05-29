//
//  SessionViewModel.swift
//  MVPSeniorProject
//
//  Created by Family on 12/29/24.
//

import Foundation
import FirebaseFunctions


@MainActor
class SessionViewModel: ObservableObject {
    @Published var interval = 0
    
    func createCheckinSession(childId: String) async throws {
        try await SessionService.shared.createCheckinSession(childId: childId, interval: interval)
    }
    
    func updateSessionReferenceInParent() async throws {
        try await SessionService.shared.addSessionReferenceToParent()
    }
    
    func startCheckinSession(interval: Int) {
        let functions = Functions.functions()

        // Call the Firebase function
        functions.httpsCallable("startCheckinSession").call(["interval": interval]) { result, error in
            if let error = error as? NSError {
                print("Error calling function: \(error.localizedDescription)")
                return
            }

            // No need to handle any return value here
            print("Check-in session started successfully!")
        }
    }
}
