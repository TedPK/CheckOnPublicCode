//
//  CheckinSessions.swift
//  MVPSeniorProject
//
//  Created by Family on 12/29/24.
//

import Foundation
import FirebaseFirestore

struct CheckinSessions: Codable, Hashable {
    let parentReference: DocumentReference
    let childReference: DocumentReference
    let startTime: Date
    let endTime: Date?
    let interval: Int
}
