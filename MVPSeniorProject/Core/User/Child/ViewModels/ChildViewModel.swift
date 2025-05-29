//
//  ChildViewModel.swift
//  MVPSeniorProject
//
//  Created by Family on 2/7/25.
//


import SwiftUI
import FirebaseFirestore
import FirebaseAuth

@MainActor
class ChildViewModel: ObservableObject {
    @Published var checkins: [Checkin] = []  // Array to hold the check-ins
    @Published var isLoading: Bool = false  // Loading state to show a spinner
    @Published var errorMessage: String? = nil  // Store any error messages
    
    private var checkinsListener: ListenerRegistration?
    
    
    // Function to fetch the first batch of check-ins (or subsequent batches for pagination)
    func fetchCheckins() async {
        isLoading = true  // Set loading state to true while fetching
        errorMessage = nil  // Clear any previous errors
        
        do {
            // Fetch the check-ins
            let fetchedCheckins = await CheckinService.shared.fetchCurrentUserCheckins() ?? []
            
            // Assign the fetched check-ins to the @Published property
            self.checkins = fetchedCheckins  // Update the checkins array
            
        }
        
        isLoading = false  // Set loading state to false when done
    }
    
    func startListeningForCheckins() {
        guard let childRef = UserService.shared.getCurrentUserDocumentReference() else {
            print("No current user reference found.")
            return
        }
        
        print("ChildRef being used for listener: \(childRef.path)")
        print("ChildRef being used for listener: \(childRef)")
        
        isLoading = true
        checkinsListener = Firestore.firestore()
            .collection("checkins")
            .order(by: "timeCheckinCreated", descending: true) // or any relevant field
            .whereField("childPath", isEqualTo: childRef.path)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                self.isLoading = false
                if let snapshot = snapshot {
                    self.checkins = snapshot.documents.compactMap {
                        try? $0.data(as: Checkin.self)
                    }
                } else if let error = error {
                    print("Error listening for checkins: \(error.localizedDescription)")
                }
            }
    }
    
    
    func stopListeningForCheckins() {
        checkinsListener?.remove()
    }
}
