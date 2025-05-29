//
//  Constants.swift
//  SeniorProjectApp
//
//  Created by Family on 10/13/24.
//

import Foundation
import Firebase
import SwiftUI


struct Constants {
    
    static let UserCollection = Firestore.firestore().collection("users")
    static let ChildCollection = Firestore.firestore().collection("children")
    static let DaysOfWeek: [String] = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    static let periods: [String] = ["30 min", "45 min", "1 hour", "2 hours", "3 hours"]
    static public var navyBlue: Color {
        Color(red: 0.0, green: 0.0, blue: 0.25)
    }
    
}
