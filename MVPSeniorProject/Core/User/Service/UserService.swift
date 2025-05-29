//
//  UserService.swift
//  SeniorProjectApp
//
//  Created by Family on 10/12/24.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

class UserService {
    
    @Published var currentUser: User?
    static let shared = UserService()
    
    
    @MainActor
    func fetchCurrentUser() async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let snapshot = try await Firestore.firestore().collection("users").document(uid).getDocument()
        let user = try snapshot.data(as: User.self) // converts user to User object
        self.currentUser = user
    }
    
    func getCurrentUserDocumentReference() -> DocumentReference? {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("No authenticated user.")
            return nil
        }
        return Firestore.firestore().collection("users").document(uid)
    }
    
    func fetchCurrentUserData() async throws -> User? { //GOOD
        guard let uid = Auth.auth().currentUser?.uid else {
            print("No authenticated user found.")
            return nil
        }
        
        do {
            let snapshot = try await Firestore.firestore().collection("users").document(uid).getDocument()
            
            // Check if the document exists and if it has data
            guard let data = snapshot.data() else {
                print("No data found for user \(uid)")
                return nil
            }
            
            // Debugging to see the raw data
            print("Fetched user data: \(data)")
            
            // Try decoding into the User object
            let user = try snapshot.data(as: User.self)
            
            // Debugging to check the decoded user model
            print("Decoded user: \(user)")
            
            return user
        } catch {
            print("Error fetching data from Firestore: \(error.localizedDescription)")
            return nil
        }
    }
    
    func setPendingToFalse(child: User) async {
        guard let childId = child.uid else {
            print("No child id found.")
            return
        }
        let childRef = Firestore.firestore().collection("users").document(childId)
        let updatedData: [String: Any] = [
            "checkinPending": false // Replace with the field and value you want to update
        ]
        do {
            try await childRef.updateData(updatedData)
            print("checkinPending set to false!")
        } catch {
            print("Error updating document: \(error.localizedDescription)")
        }
    }
    
    func fetchChildren() async -> [User]? { // GOOD
        guard let uid = Auth.auth().currentUser?.uid else {
            print("No authenticated user found.")
            return nil
        }
        
        do {
            // Fetch the user document reference
            let userRef = Firestore.firestore().collection("users").document(uid)
            let userData = try await userRef.getDocument().data(as: User?.self)
            
            guard let circleRef = userData?.circleReference as? DocumentReference else {
                print("User does not have a circleReference.")
                return nil
            }
            
            // Fetch the circle data to get the children references
            let circleData = try await circleRef.getDocument().data(as: Circle?.self)
            guard let childrenRefs = circleData?.children as? [DocumentReference] else {
                print("No children found in the circle.")
                return nil
            }
            
            // Fetch children from the users collection
            var children: [User] = []
            for childRef in childrenRefs {
                let childData = try await childRef.getDocument().data(as: User?.self)
                if let child = childData {
                    children.append(child)
                }
            }
            
            return children
        } catch {
            print("Error fetching children from Firestore: \(error.localizedDescription)")
            return nil
        }
    }
    
    func getUserFirstName(from reference: DocumentReference) async -> String? {
        do {
            let snapshot = try await reference.getDocument()
            guard let data = snapshot.data() else {
                print("No data found for the given reference.")
                return nil
            }
            
            // Assuming your Firestore `users` documents have a "firstName" field
            if let firstName = data["firstName"] as? String {
                return firstName
            } else {
                print("First name not found in user data.")
                return nil
            }
        } catch {
            print("Error fetching user document: \(error.localizedDescription)")
            return nil
        }
    }
}
