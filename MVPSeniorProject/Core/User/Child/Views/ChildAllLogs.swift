//
//  ChildAllLogs.swift
//  MVPSeniorProject
//
//  Created by Family on 2/9/25.
//


import SwiftUI

struct ChildAllLogs: View {
    
    @StateObject private var childViewModel = ChildViewModel()
    @State private var showFullLogsView = false // Declare state for full logs view
    
    var body: some View {
        NavigationStack {
            VStack {
                
                // Show loading spinner while fetching logs
                if childViewModel.isLoading {
                    ProgressView("Loading logs...")
                        .padding()
                } else if let errorMessage = childViewModel.errorMessage {
                    // Display error message if failed to load
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    // Display logs in ScrollView
                    ScrollView {
                        VStack(spacing: 10) {
                            // Show check-ins
                            ForEach(childViewModel.checkins, id: \.id) { checkin in
                                LogView(checkin: checkin) // Custom LogView for each check-in
                            }
                        }
                    }
                }
                
                // Show a loading spinner if more check-ins are being loaded
                if childViewModel.isLoading {
                    ProgressView("Loading more...")
                        .padding()
                }
            }
        }
        .padding()
        .navigationTitle("All Check-Ins")
        .onAppear {
            Task {
                await childViewModel.fetchCheckins()
                childViewModel.startListeningForCheckins()
            }
        }
        .onDisappear {
            childViewModel.stopListeningForCheckins()
        }
    }
}

#Preview {
    ChildAllLogs()
}
