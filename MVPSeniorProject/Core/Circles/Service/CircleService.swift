//
//  CircleService.swift
//  MVPSeniorProject
//
//  Created by Family on 12/4/24.
//

import Firebase
import FirebaseAuth
import UIKit
import FirebaseFirestore

class CircleService {
    
    static let shared = CircleService()
    
    func createCircleJoinCode() -> String { //GOOD
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        var code = ""
        
        for _ in 0..<6 {
            if let randomLetter = letters.randomElement() {
                code.append(randomLetter)
            }
        }
        
        return code
    }
    
    func createCircle() async throws { //GOOD
        guard let user = Auth.auth().currentUser else {
            print("No authenticated user found.")
            return
        }
        
        // Fetch the user document reference for the current user
        let userRef = Firestore.firestore().collection("users").document(user.uid)
        
        // Initialize the circle object
        let newCode = createCircleJoinCode()
        let circle = Circle(parent: userRef, joinCode: newCode, circleId: "", joinCodeInitialization: Timestamp())
        
        // Encode the circle to Firestore-compatible format
        guard let encodedCircle = try? Firestore.Encoder().encode(circle) else {
            print("Failed to encode circle.")
            return
        }
        
        // Add the circle document to Firestore
        let circleRef = try await Firestore.firestore().collection("circles").addDocument(data: encodedCircle)
        
        // Get the generated document ID for the circle
        let circleId = circleRef.documentID
        
        // Update the circle document with its own ID (optional, if you want to set circleId manually)
        try await circleRef.updateData([
            "circleId": circleId
        ])
        
        // Update the user's document with the circle reference and their role
        try await userRef.updateData([
            "circleReference": circleRef,
            "role": User.Role.parent.rawValue
        ])
        
        print("Circle created successfully with ID: \(circleId)")
    }
    
    func getUserRole() async -> User.Role? { //GOOD
        guard let uid = Auth.auth().currentUser?.uid else {
            print("No authenticated user found(Circle Service)")
            return nil
        } // print and return
        // OF COURSE THIS RETURNS AN ERROR SINCE A NEW USER IS NOT PART OF A CIRCLE DIPSHIT
        do {
            let userRef = try await Firestore.firestore().collection("users").document(uid).getDocument()
            let userData = try userRef.data(as: User?.self)
            let role = userData?.role//PERHAPS RAW VALUE
            return role
        } catch let error {
            print("Error fetching data from Firestore: \(error.localizedDescription)")
            return nil
        }
    }
    
    func parentCloseCircle() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("No authenticated user found (Circle Service)")
            return
        }

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(uid)

        do {
            // Fetch the parent user's data
            let userSnapshot = try await userRef.getDocument()
            let userData = try userSnapshot.data(as: User?.self)

            guard let circleRef = userData?.circleReference else {
                print("No circle reference found")
                return
            }

            // Fetch circle data
            let circleSnapshot = try await circleRef.getDocument()
            let circleData = try circleSnapshot.data(as: Circle?.self)
            let children = circleData?.children ?? []

            // Handle each child
            for childRef in children {
                let childSnapshot = try await childRef.getDocument()
                if let checkinRefs = childSnapshot.data()?["checkins"] as? [DocumentReference] {
                    for checkinRef in checkinRefs {
                        do {
                            try await checkinRef.delete()
                            print("Deleted child check-in at \(checkinRef.path)")
                        } catch {
                            print("Failed to delete check-in \(checkinRef.path): \(error.localizedDescription)")
                        }
                    }
                }

                // Remove circle and role from child
                try await childRef.updateData([
                    "checkins": FieldValue.delete(),
                    "circleReference": FieldValue.delete(),
                    "role": User.Role.noRole.rawValue
                ])
            }

            // Optionally delete parent’s checkins (if applicable)
            if let checkins = userSnapshot.data()?["checkins"] as? [DocumentReference] {
                for checkin in checkins {
                    try await checkin.delete()
                }
            }

            // Update parent
            try await userRef.updateData([
                "checkins": FieldValue.delete(),
                "circleReference": FieldValue.delete(),
                "role": User.Role.noRole.rawValue
            ])

            // Delete the circle document
            try await circleRef.delete()

            print("Circle closed, all children and parent data cleaned.")

        } catch {
            print("Error closing the circle: \(error.localizedDescription)")
        }
    }
    
    func childLeaveCircle() async {
        // Ensure that the current user ID is available
        guard let uid = Auth.auth().currentUser?.uid else {
            print("No authenticated user found. Cannot remove child from circle.")
            return
        }

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(uid)

        do {
            // Fetch user data
            let userSnapshot = try await userRef.getDocument()
            let userData = try userSnapshot.data(as: User?.self)
            
            // Delete all check-in documents
            if let checkinRefs = userSnapshot.data()?["checkins"] as? [DocumentReference] {
                for ref in checkinRefs {
                    do {
                        try await ref.delete()
                        print("Deleted check-in at \(ref.path)")
                    } catch {
                        print("Failed to delete check-in at \(ref.path): \(error.localizedDescription)")
                    }
                }
                
                // Optionally clear the checkins array on the user document
                try await userRef.updateData([
                    "checkins": FieldValue.delete()
                ])
            }
            
            // Remove child from circle
            guard let circleRef = userData?.circleReference else {
                print("No circle reference found for current user")
                return
            }

            let circleSnapshot = try await circleRef.getDocument()
            let circleData = try circleSnapshot.data(as: Circle?.self)
            guard let childrenRefs = circleData?.children else {
                print("No children found in the circle")
                return
            }

            let updatedChildrenRefs = childrenRefs.filter { $0 != userRef }

            try await circleRef.updateData([
                "children": updatedChildrenRefs
            ])

            // Clear circle and role
            try await userRef.updateData([
                "circleReference": FieldValue.delete(),
                "role": User.Role.noRole.rawValue
            ])

            print("Successfully removed user with UID \(uid) from the circle and deleted check-ins.")

        } catch {
            print("Error removing user from circle with UID \(uid): \(error.localizedDescription)")
        }
    }

    
    func checkCircleCodeExists(code: String) async -> Bool { //GOOD
        do {
            // Query the circles collection for a document where the "code" field matches the provided code
            let querySnapshot = try await Firestore.firestore().collection("circles")
                .whereField("joinCode", isEqualTo: code)
                .getDocuments()
            
            // If the query snapshot contains any documents, it means the code was found
            if !querySnapshot.isEmpty {
                return true
            }
        } catch {
            print("Error checking circle code: \(error.localizedDescription)")
        }
        
        // If no documents were found, return false
        return false
    }

    @MainActor
    func getCircleRef(byCode code: String) async -> DocumentReference? { // GOOD
        
        print("Searching for code: \(code)")
        do {
            // Query Firestore to find the circle with the matching code
            let querySnapshot = try await Firestore.firestore().collection("circles").whereField("joinCode", isEqualTo: code).getDocuments()
            
            print("Query: \(querySnapshot.query)")
            
            // Check if a document was found
            guard !querySnapshot.isEmpty else {
                print("No circle found with code: \(code)")
                return nil
            }
            
            if let document = querySnapshot.documents.first {
                return document.reference
            }
            
        } catch {
            // Print error with a more descriptive message
            print("Error retrieving circle with code \(code): \(error.localizedDescription)")
            return nil
        }
        return nil
    }

    @MainActor
    func addUserToCircle(circleRef: DocumentReference) async throws { //GOOD
        // Ensure the current user is authenticated
        guard let uid = Auth.auth().currentUser?.uid else {
            print("No authenticated user found. Cannot remove child from circle.")
            return
        }

        // Start a background task to perform the Firestore operation
        await Task.detached(priority: .userInitiated) { [uid, circleRef] in
            do {
                // Firestore reference to the current user document
                let userRef = Firestore.firestore().collection("users").document(uid)
                
                // Update the user's role and circleId to indicate they are no longer in the circle
                try await userRef.updateData([
                    "circleReference": circleRef,
                    "role": User.Role.child.rawValue
                ])
                try await circleRef.updateData([
                    "children": FieldValue.arrayUnion([userRef])
                    ])
                
                // Log success for debugging
                print("Successfully added user with UID \(uid) to the circle.")
                
            } catch {
                // Log error with more descriptive message
                print("Error adding user to circle with UID \(uid): \(error.localizedDescription)")
            }
        }.value
    }
    
    func codeExpired() async -> Bool? {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("No authenticated user found.")
            return nil
        }
        
        do {
            let userRef = Firestore.firestore().collection("users").document(uid)
            let userData = try await userRef.getDocument().data(as: User.self)
            
            guard let circleRef = userData.circleReference else {
                print("No circle reference found.")
                return nil
            }
            let circleData = try await circleRef.getDocument().data(as: Circle?.self)
            if let joinCodeInitTime = circleData?.joinCodeInitialization as? Timestamp {
                let currentDate = Date()
                let initDate = joinCodeInitTime.dateValue()
                let timeDifference = currentDate.timeIntervalSince(initDate) // Time in seconds
                
                if timeDifference > 1800 {
                    print("The code has expired (more than 30 minutes).")
                    return true
                } else {
                    print("The code is still valid (within 30 minutes).")
                    return false
                }
            } else {
                print("No code initialization timestamp found.")
                return nil
            }
        } catch {
            print("Error fetching expiration status: \(error.localizedDescription)")
            return nil
        }
    }
    
    func setNewCode() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("No authenticated user found.")
            return
        }
        do {
            let userRef = Firestore.firestore().collection("users").document(uid)
            let userData = try await userRef.getDocument().data(as: User.self)
            
            guard let circleRef = userData.circleReference else {
                print("No circle reference found.")
                return
            }
            
            let newCode = createCircleJoinCode() // Assuming this is defined elsewhere
            try await circleRef.updateData([
                "joinCode": newCode,
                "joinCodeInitialization": Timestamp()
            ])
            print("New join code set successfully.")
        } catch {
            print("Error setting new code: \(error.localizedDescription)")
        }
    }
    
    func fetchCurrentCode() async -> String? {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("No authenticated user found.")
            return nil
        }

        do {
            let userRef = Firestore.firestore().collection("users").document(uid)
            let userData = try await userRef.getDocument().data(as: User.self)
            
            guard let circleRef = userData.circleReference else {
                print("No circle reference found.")
                return nil
            }
            
            let circleData = try await circleRef.getDocument().data(as: Circle.self)
            return circleData.joinCode
        } catch {
            print("Error fetching current code: \(error.localizedDescription)")
            return nil
        }
    }
}
