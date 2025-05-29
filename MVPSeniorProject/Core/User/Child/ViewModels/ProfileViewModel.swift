//
//  ProfileViewModel.swift
//  MVPSeniorProject
//
//  Created by Family on 12/22/24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import Firebase

class ProfileViewModel: ObservableObject {
    
    // Published properties to store user data
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var email: String = ""
    @Published var checkinPending: Bool = false
    private var pendingStatusListener: ListenerRegistration?
    
    // Fetch user data from the service
//    @MainActor
//    func fetchUserData() async {
//        do {
//            // Assuming `UserService.shared.fetchCurrentUserData()` fetches user data from an API or database
//            if let user = try await UserService.shared.fetchCurrentUserData() {
//                // Update the profile properties with fetched data
//                firstName = user.firstName
//                lastName = user.lastName
//                email = user.email
//                checkinPending = user.checkinPending
//            } else {
//                // If user data is unavailable, show an appropriate message
//                print("User data not available.") // THIS WAS CALLED ERROR
//            }
//        } catch {
//            // Handle the error by setting an error message
//            print("Error fetching user info: \(error.localizedDescription)")
//        }
//    }
    
    @MainActor
    func fetchUserData() async {
        do {
            // Step 1: Load user data via your existing service
            if let user = try await UserService.shared.fetchCurrentUserData() {
                firstName = user.firstName
                lastName = user.lastName
                email = user.email
                // Don't assign checkinPending yet — we'll determine it from Firestore
            } else {
                print("User data not available.")
            }

            // Step 2: Check Firestore for the last check-in status
            guard let uid = Auth.auth().currentUser?.uid else { return }
            let db = Firestore.firestore()
            let userRef = db.collection("users").document(uid)
            let userDoc = try await userRef.getDocument()

            if let checkins = userDoc.data()?["checkins"] as? [DocumentReference], !checkins.isEmpty {
                let lastCheckin = checkins.last
                let checkinDoc = try await lastCheckin?.getDocument()
                
                if let status = checkinDoc?.data()?["checkinStatus"] as? String {
                    self.checkinPending = (status == "pending")
                } else {
                    self.checkinPending = false
                }
            } else {
                self.checkinPending = false
            }
            
        } catch {
            print("Error fetching user info: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func updateChildResponse(childResponse: String) async {
        do {
            // Call the service method that updates the child response.
            let result = await CheckinService.shared.updateChildResponse(childResponse: childResponse)
            
            // Check if the result is true (unwrapping optional).
            if let result = result, result {
                self.checkinPending.toggle()  // Toggle the check-in pending state.
            } else {
                // Handle the case where result is nil or false, if needed.
                print("Failed to update child response.")
            }
        }
    }
    
    func startListeningForPendingStatus() {
        guard let childRef = UserService.shared.getCurrentUserDocumentReference() else {
            print("No current user reference found.")
            return
        }

        print("Listening to user doc at path: \(childRef.path)")

        pendingStatusListener = childRef.addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }

            if let error = error {
                print("Error listening for checkinPending: \(error.localizedDescription)")
                return
            }

            guard let snapshot = snapshot, snapshot.exists else {
                print("Document does not exist.")
                return
            }

            let data = snapshot.data()
            let checkinPending = data?["checkinPending"] as? Bool ?? false
            print("checkinPending updated to: \(checkinPending)")
            self.checkinPending = checkinPending
        }
    }
    
    
    func stopListeningForPendingStatus() {
        print("PendingStatusListener: Removing listener.")
        pendingStatusListener?.remove()
    }
}
