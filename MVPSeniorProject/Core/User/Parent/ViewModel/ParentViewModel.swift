//
//  ParentMainViewModel.swift
//  MVPSeniorProject
//
//  Created by Family on 12/8/24.
//

import Foundation
import FirebaseFirestore


@MainActor
class ParentViewModel: ObservableObject {
    @Published var children: [User] = []
    @Published var checkins: [Checkin] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private var checkinsListener: ListenerRegistration?
    

//    func startListeningForCheckins() {
//        guard let parentRef = UserService.shared.getCurrentUserDocumentReference() else {
//            print("No current user reference found.")
//            return
//        }
//        
//        isLoading = true
//        checkinsListener = Firestore.firestore()
//            .collection("checkins")
//            .order(by: "timeCheckinCreated", descending: true) // or any relevant field
//            .whereField("parentPath", isEqualTo: parentRef.path)
//            .addSnapshotListener { [weak self] snapshot, error in
//                guard let self = self else { return }
//                self.isLoading = false
//                if let snapshot = snapshot {
//                    self.checkins = snapshot.documents.compactMap {
//                        try? $0.data(as: Checkin.self)
//                    }
//                } else if let error = error {
//                    print("Error listening for checkins: \(error.localizedDescription)")
//                }
//            }
//    }
    
    func startListeningForCheckins(forSpecificChild child: User? = nil) {
        guard let parentRef = UserService.shared.getCurrentUserDocumentReference() else {
            print("ParentViewModel: No current user reference found.")
            self.errorMessage = "Cannot identify current parent user."
            self.isLoading = false
            return
        }
        print("ParentViewModel: Setting up listener with parentRef.path: \(parentRef.path)")

        isLoading = true
        self.errorMessage = nil // Clear previous errors

        var query: Query = Firestore.firestore()
            .collection("checkins")
            .whereField("parentPath", isEqualTo: parentRef.path)

        // Add child filter if a specific child is provided
        // This assumes:
        // 1. Your `User` model has an `id` property which is the child's UID (document ID in 'users' collection).
        // 2. Your `Checkin` documents in Firestore have a `childPath` field storing the string "users/CHILD_UID".
        if let specificChild = child, let childUID = specificChild.id { // Ensure User has 'id'
            let expectedChildPath = Firestore.firestore().collection("users").document(childUID).path
            print("ParentViewModel: Adding child filter for childPath: \(expectedChildPath)")
            query = query.whereField("childPath", isEqualTo: expectedChildPath)
        } else if child != nil && child?.id == nil {
             print("ParentViewModel: Warning - specificChild provided but its ID is nil. Listener will fetch for all children of the parent.")
        }
        
        // Apply ordering
        query = query.order(by: "timeCheckinCreated", descending: true)

        checkinsListener?.remove() // Remove previous listener before attaching a new one

        checkinsListener = query.addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            self.isLoading = false

            if let error = error {
                print("ParentViewModel: Error listening for checkins: \(error.localizedDescription)")
                self.errorMessage = "Error fetching updates: \(error.localizedDescription)"
                // Check console for Firestore indexing links if this error occurs
                return
            }

            if let snapshot = snapshot {
                print("ParentViewModel: Listener received snapshot. Document count: \(snapshot.documents.count)")
                // Log document changes for debugging
                snapshot.documentChanges.forEach { diff in
                    print("ParentViewModel: Change type: \(diff.type), Doc ID: \(diff.document.documentID), Data: \(diff.document.data())")
                }
                
                let newCheckins = snapshot.documents.compactMap { document -> Checkin? in
                    do {
                        let checkin = try document.data(as: Checkin.self)
                        // print("ParentViewModel: Successfully decoded checkin: \(checkin.id ?? "No ID")")
                        return checkin
                    } catch {
                        print("ParentViewModel: Failed to decode checkin document \(document.documentID): \(error)")
                        print("ParentViewModel: Raw data for failed decode: \(document.data())")
                        // Optionally, preserve existing error message or set a new one for decoding issues
                        // self.errorMessage = "Problem decoding checkin data."
                        return nil
                    }
                }
                self.checkins = newCheckins
                
                if newCheckins.isEmpty && !snapshot.documents.isEmpty {
                     print("ParentViewModel: All documents received from listener failed to decode.")
                     // self.errorMessage = "Failed to process some check-in data." // Consider user-facing message
                } else if newCheckins.isEmpty && snapshot.documents.isEmpty {
                     print("ParentViewModel: No documents matched the listener's query for this parent/child.")
                }

            } else {
                print("ParentViewModel: Listener returned nil snapshot and nil error.")
                self.errorMessage = "Failed to get data updates."
            }
        }
    }
    
    
    func stopListeningForCheckins() {
        checkinsListener?.remove()
    }
    

    func loadChildren() async {
        isLoading = true
        defer { isLoading = false }
        if let names = await UserService.shared.fetchChildren() {
            self.children = names
        } else {
            print("No children")
        }
    }
    func fetchCheckins(child: User) async {
        isLoading = true  // Set loading state to true while fetching
        errorMessage = nil
        
        do {
            // Fetch the check-ins
            let fetchedCheckins = await CheckinService.shared.fetchChildCheckins(child: child) ?? []
            
            // Assign the fetched check-ins to the @Published property
            self.checkins = fetchedCheckins  // Update the checkins array
            
        }
        
        isLoading = false  // Set loading state to false when done
    }

}
