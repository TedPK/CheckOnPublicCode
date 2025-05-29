//
//  Notification.swift
//  MVPSeniorProject
//
//  Created by Family on 12/29/24.
//

import Foundation
import FirebaseFirestore

struct Notification: Codable, Identifiable, Hashable {
    @DocumentID var id: String?
    let type: NotificationType
    let senderReference: DocumentReference
    let receiverReference: DocumentReference
    let checkinId: String?
    let sentAt: Date
    let read: Date
//    let payload: MapKeyType - may need something like this but I may be able to create a message based off of the type of notification it is
    
    
    enum NotificationType: String, Codable {
        case checkin
        case statusUpdate
    }
}
