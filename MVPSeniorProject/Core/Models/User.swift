//
//  User.swift
//  SeniorProjectApp
//
//  Created by Family on 10/12/24.
//

import Foundation
import FirebaseFirestore

struct User: Codable, Identifiable, Hashable {
    @DocumentID var uid: String?
    let firstName: String
    let email: String
    let lastName: String
    let id: String?
    var role: Role
    var circleReference: DocumentReference? // not sure about any of this document reference bullshit
    var checkinPending: Bool
    var checkins: [DocumentReference]? // especially here, idk how this will work
    var schedules: [DocumentReference]?
    let fcmToken: String?
    let checkinSessionReference: DocumentReference?
    
    enum Role: String, Codable {
        case parent
        case child
        case noRole
    }
}

extension User {
    static let MOCK_USER = User(firstName: "Tom", email: "tom@gmail.com", lastName: "Grango", id: "", role: .noRole, checkinPending: true, fcmToken: "token", checkinSessionReference: nil)
}
