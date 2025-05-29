//
//  Untitled.swift
//  MVPSeniorProject
//
//  Created by Family on 12/4/24.
//

import Foundation
import FirebaseFirestore

struct Circle: Codable, Identifiable, Hashable {
    @DocumentID var id: String?
    let parent: DocumentReference
    var joinCode: String
    let circleId: String?
    var joinCodeInitialization: Timestamp
    var children: [DocumentReference]?
}
