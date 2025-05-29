//
//  ParentLogView.swift
//  MVPSeniorProject
//
//  Created by Family on 12/29/24.
//

import SwiftUI

struct ParentLogView: View {
    var child: User
    @StateObject private var viewModel = ParentViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                
                // Show loading spinner while fetching logs
                if viewModel.isLoading {
                    ProgressView("Loading logs...")
                        .padding()
                } else if let errorMessage = viewModel.errorMessage {
                    // Display error message if failed to load
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    // Display logs in ScrollView
                    ScrollView {
                        VStack(spacing: 10) {
                            // Show check-ins
                            ForEach(Array(viewModel.checkins), id: \.id) { checkin in
                                LogView(checkin: checkin) // Custom LogView for each check-in
                            }
                        }
                    }
                }
                
                // Show a loading spinner if more check-ins are being loaded
                if viewModel.isLoading {
                    ProgressView("Loading more...")
                        .padding()
                }
            }
        }
        .padding()
        .navigationTitle("All Check-Ins")
        .onAppear {
            Task {
                await viewModel.fetchCheckins(child: child)
                viewModel.startListeningForCheckins()
            }
        }
        .onDisappear {
            viewModel.stopListeningForCheckins()
        }
    }
}

#Preview {
    ParentLogView(child: User.MOCK_USER)
}
