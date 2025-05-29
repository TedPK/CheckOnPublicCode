//
//  Checkin.swift
//  MVPSeniorProject
//
//  Created by Family on 12/25/24.
//

import Foundation
import FirebaseFirestore
import FirebaseCore

struct Checkin: Codable, Identifiable, Hashable {
    @DocumentID var id: String?
    let checkinId: String?
    let parentPath: String?
    let childPath: String?
    let parentRef: DocumentReference?
    let childRef: DocumentReference?
    let timeCheckinCreated: Timestamp?
    let checkinStatus: String
    let timeStatusReceived: Timestamp?
}

extension Checkin {
    static let MOCK_CHECKIN = Checkin(checkinId: "ijdiemiekd", parentPath: "knmdikenodem", childPath: "knnekfe", parentRef: nil, childRef: nil, timeCheckinCreated: Timestamp(), checkinStatus: "pending", timeStatusReceived: Timestamp())
}
