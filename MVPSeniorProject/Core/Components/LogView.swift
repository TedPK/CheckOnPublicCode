////
////  LogView.swift
////  MVPSeniorProject
////
////  Created by Family on 2/8/25.
////
//
//import SwiftUI
//
//struct LogView: View {
//    
//    var checkin: Checkin  // Assuming you have a Checkin model containing the relevant data
//
//    var body: some View {
//        
//        guard let childRef = checkin.childRef else {
//            return Text("Error: Missing child reference.")
//            
//            if let childFirstName = await UserService.shared.getUserFirstName(childRef) {
//                print("Child's name is \(childFirstName)")
//            } else {
//                print("Could not fetch child's name.")
//            }
//        } else {
//            print("error 01976372")
//        }
//
//            
//        }
//        VStack {
//            HStack {
//                // Top-left: "Checkin" text with Date and Time
//                VStack(alignment: .leading, spacing: 5) {
//                    HStack {
//                        Text("Check-In")
//                            .font(.headline)
//                            .foregroundColor(Color(.white))
//                        Text()
//                    }
//                    
//                    // Safely unwrap the checkinDate and handle invalid date cases
//                    if let checkinDate = checkin.timeCheckinCreated?.dateValue() {
//                        // Display formatted date and time side by side
//                        HStack {
//                            Text(checkinDate, style: .date) // Date
//                                .font(.subheadline)
//                                .foregroundColor(.gray)
//                            
//                            Text(checkinDate, style: .time) // Time
//                                .font(.subheadline)
//                                .foregroundColor(.gray)
//                        }
//                    } else {
//                        Text("Invalid Date") // Default message if the Date is nil
//                            .font(.subheadline)
//                            .foregroundColor(.gray)
//                    }
//                }
//                Spacer()
//                
//                // Top-right: Status of the check-in
//                VStack {
//                    Text(checkin.checkinStatus.capitalized) // Capitalize status
//                        .font(.headline)
//                        .foregroundColor(
//                            checkin.checkinStatus == "pending" ? .yellow :
//                            checkin.checkinStatus == "good" ? .green :
//                            checkin.checkinStatus == "bad" ? .red : .purple
//                        )
//                        .padding(5)
//                        .background(
//                            checkin.checkinStatus == "pending" ? Color.yellow.opacity(0.2) :
//                            checkin.checkinStatus == "good" ? Color.green.opacity(0.2) :
//                            checkin.checkinStatus == "bad" ? Color.red.opacity(0.2) : Color.purple.opacity(0.2)
//                        )
//                        .cornerRadius(8)
//                }
//            }
//        }
//        .frame(maxWidth: .infinity)
//        .padding()
//        .background(Color(.darkGray))
//        .cornerRadius(12)
//        .shadow(radius: 5)
//        .padding([.top, .horizontal]) // Add padding around the entire view
//    }
//}
//
//#Preview {
//    LogView(checkin: Checkin.MOCK_CHECKIN) // Replace with your mock or real data
//}
//

//
//  LogView.swift
//  MVPSeniorProject
//
//  Created by Family on 2/8/25.
//

import SwiftUI
import FirebaseFirestore


struct LogView: View {
    
    var checkin: Checkin  // Your Checkin model
    @State private var childFirstName: String = "Loading..." // <-- Start with a loading state
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    // Use the fetched child's first name
                    
                    HStack {
                        Text("Check-In")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text(childFirstName)
                            .font(.caption)
                            .foregroundColor(.primary)
                    }

                    
                    if let checkinDate = checkin.timeCheckinCreated?.dateValue() {
                        HStack {
                            Text(checkinDate, style: .date)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text(checkinDate, style: .time)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    } else {
                        Text("Invalid Date")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                Spacer()
                
                VStack {
                    Text(checkin.checkinStatus.capitalized)
                        .font(.headline)
                        .foregroundColor(
                            checkin.checkinStatus == "pending" ? .yellow :
                            checkin.checkinStatus == "good" ? .green :
                            checkin.checkinStatus == "bad" ? .red : .purple
                        )
                        .padding(5)
                        .background(
                            checkin.checkinStatus == "pending" ? Color.yellow.opacity(0.2) :
                            checkin.checkinStatus == "good" ? Color.green.opacity(0.2) :
                            checkin.checkinStatus == "bad" ? Color.red.opacity(0.2) : Color.purple.opacity(0.2)
                        )
                        .cornerRadius(8)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.darkGray))
        .cornerRadius(12)
        .shadow(radius: 5)
        .padding([.top, .horizontal])
        .task { // <-- this runs when the view appears
            await fetchChildName()
        }
    }
    
    @MainActor
    func fetchChildName() async {
        guard let childRef = checkin.childRef else {
            childFirstName = "No Child Ref"
            return
        }
        
        if let name = await UserService.shared.getUserFirstName(from: childRef) {
            childFirstName = name
        } else {
            childFirstName = "Unknown Child"
        }
    }
}

#Preview {
    LogView(checkin: Checkin.MOCK_CHECKIN) // Replace with your mock or real data
}
