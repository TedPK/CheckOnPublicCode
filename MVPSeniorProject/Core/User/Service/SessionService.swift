//
//  SessionService.swift
//  MVPSeniorProject
//
//  Created by Family on 12/29/24.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class SessionService {
    
    static let shared = SessionService()
    
    @MainActor
    func createCheckinSession(childId: String, interval: Int) async throws { // the document id of the checkinSession should be the same as the parents id
        guard let uid = Auth.auth().currentUser?.uid else {
            print("No authenticated user found.")
            return
        }
        
        do {
            let parentRef = Firestore.firestore().collection("users").document(uid)
            let childRef = Firestore.firestore().collection("users").document(childId)
            
            let session = CheckinSessions(parentReference: parentRef, childReference: childRef, startTime: Date(), endTime: nil, interval: interval)
            guard let encodedSession = try? Firestore.Encoder().encode(session) else { return }
            try await Firestore.firestore().collection("checkinSessions").document(uid).setData(encodedSession)
        } catch {
            print("Error creating session \(error.localizedDescription)")
        }
    }
    
    //add session reference to parent
    func addSessionReferenceToParent() async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("No authenticated user found.")
            return
        }
        
        do {
            let sessionRef = Firestore.firestore().collection("checkinSession").document(uid)
            let parentRef = Firestore.firestore().collection("users").document(uid)
            try await parentRef.updateData(["checkinSessionReference": sessionRef])
        } catch {
            print("Error adding sessionRef to parent: \(error.localizedDescription)")
        }
    }
    
    func hasSessionReference() async throws -> Bool? {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("No authenticated user found.")
            return nil
        }
        
        do {
            let parentRef = Firestore.firestore().collection("users").document(uid)
            let parentData = try await parentRef.getDocument().data(as: User?.self)
            let sessionRef = parentData?.checkinSessionReference
            if sessionRef == nil {
                print("No sessionRef found")
                return false
            } else {
                print("SessionRef found")
                return true
            }
        } catch {
            return nil
        }
    }
    
    //delete session doc
    func deleteSessionDocument() async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("No authenticated user found.")
            return
        }
        do {
            let sessionRef = Firestore.firestore().collection("checkinSessions").document(uid)
            try await sessionRef.delete()
            print("Sessions document successfully deleted.")
        }
    }
    
    //remove sessionref from parent
    func removeSessionRefFromParent() async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("No authenticated user found.")
            return
        }
        let parentRef = Firestore.firestore().collection("users").document(uid)
        do {
            // Update the document to remove the session reference
            try await parentRef.updateData(["checkinSessionReference": FieldValue.delete()])
            print("Session reference removed successfully.")
        } catch {
            // Log the error and rethrow it for higher-level handling
            print("Failed to remove session reference: \(error.localizedDescription)")
        }
    }
}
