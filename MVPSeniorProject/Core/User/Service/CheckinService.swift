//
//  CheckinService.swift
//  MVPSeniorProject
//
//  Created by Family on 2/6/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class CheckinService {
    
    static let shared = CheckinService()
    
    func fetchCurrentUserCheckins() async -> [Checkin]? {
        // Same as before, but return [Checkin] directly instead of [DocumentSnapshot]
        guard let uid = Auth.auth().currentUser?.uid else {
            print("No authenticated user found (Circle Service)")
            return nil
        }
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(uid)
        
        do {
            let userDoc = try await userRef.getDocument()
            
            if let checkins = userDoc.data()?["checkins"] as? [DocumentReference] {
                var checkinsList: [Checkin] = []
                
                for ref in checkins {
                    let snapshot = try await ref.getDocument()
                    
                    if snapshot.exists, let checkin = try snapshot.data(as: Checkin?.self) {
                        checkinsList.append(checkin)
                    }
                }
                print("Checkins List \(checkinsList)")
                return checkinsList
            } else {
                print("No checkins found for the user.")
                return nil
            }
        } catch {
            print("Error fetching user check-ins: \(error.localizedDescription)")
            return nil
        }
    }
    
    func fetchChildCheckins(child: User) async -> [Checkin]? {
        
        guard let childId = child.uid else {
            return nil
        }
        
        let db = Firestore.firestore()
        let childRef = db.collection("users").document(childId)
        
        do {
            let userDoc = try await childRef.getDocument()
            
            if let checkins = userDoc.data()?["checkins"] as? [DocumentReference] {
                var checkinsList: [Checkin] = []
                
                for ref in checkins {
                    let snapshot = try await ref.getDocument()
                    
                    if snapshot.exists, let checkin = try snapshot.data(as: Checkin?.self) {
                        checkinsList.append(checkin)
                    }
                }
                print("Checkins List \(checkinsList)")
                return checkinsList
            } else {
                print("No checkins found for the user.")
                return nil
            }
        } catch {
            print("Error fetching user check-ins: \(error.localizedDescription)")
            return nil
        }
    }
    
    func checkLastCheckin(child: User) async {
        
        let db = Firestore.firestore()
        guard let childId = child.uid else {
            return
        }
        let childRef = db.collection("users").document(childId)
        
        do {
            // Fetch the user document
            let childDoc = try await childRef.getDocument()
            
            // Fetch the checkins field (array of document references)
            guard let checkins = childDoc.data()?["checkins"] as? [DocumentReference], !checkins.isEmpty else {
                print("No check-ins found for the user.")
                return
            }
            
            // Get the last check-in document
            let lastCheckin = checkins.last
            guard let lastCheckin = lastCheckin else {
                print("No last check-in found.")
                return
            }
            
            // Fetch the last check-in document data
            let lastCheckinDoc = try await lastCheckin.getDocument()
            
            if lastCheckinDoc.exists {
                // Retrieve the current checkinStatus
                if let checkinStatus = lastCheckinDoc.data()?["checkinStatus"] as? String {
                    
                    // If the status is "pending", update it to "no response"
                    if checkinStatus == "pending" {
                        try await lastCheckin.updateData(["checkinStatus": "no response"])
                        print("Check-in status updated to 'no response'.")
                    } else {
                        print("Check-in status is not 'pending', no update required.")
                    }
                    
                } else {
                    print("No checkinStatus field found in the last check-in.")
                }
            } else {
                print("Last check-in document does not exist.")
            }
        } catch {
            print("Error updating check-in: \(error)")
        }
    }

    
    func updateChildResponse(childResponse: String) async -> Bool? {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("No authenticated user found (Circle Service)")
            return nil
        }
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(uid)
        
        do {
            // Fetch the user document
            let userDoc = try await userRef.getDocument()
            
            // Fetch the checkins field (array of document references)
            guard let checkins = userDoc.data()?["checkins"] as? [DocumentReference], !checkins.isEmpty else {
                print("No check-ins found for the user.")
                return nil
            }
            
            // Get the last check-in document
            let lastCheckin = checkins.last
            guard let lastCheckin = lastCheckin else {
                print("No last check-in found.")
                return nil
            }
            
            // Fetch the last check-in document data
            let lastCheckinDoc = try await lastCheckin.getDocument()
            
            if lastCheckinDoc.exists {
                // Update check-in status based on the child response
                var updatedStatus: String?
                if childResponse == "good" {
                    updatedStatus = "good"
                } else if childResponse == "bad" {
                    updatedStatus = "bad"
                }
                
                // If a valid status is provided, update the document
                if let updatedStatus = updatedStatus {
                    try await lastCheckin.updateData(["checkinStatus": updatedStatus])
                    print("Check-in status updated to \(updatedStatus).")
                    return true
                } else {
                    print("Invalid child response.")
                    return false
                }
            } else {
                print("Last check-in document does not exist.")
                return false
            }
        } catch {
            print("Error updating check-in: \(error)")
            return nil
        }
    }
}
