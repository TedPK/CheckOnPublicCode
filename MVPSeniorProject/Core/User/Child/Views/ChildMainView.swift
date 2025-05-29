//
//  ChildMainView.swift
//  MVPSeniorProject
//
//  Created by Family on 12/5/24.
//


import SwiftUI

struct ChildMainView: View {
    
    @StateObject private var profileViewModel = ProfileViewModel()
    @StateObject private var childViewModel = ChildViewModel()
    @State private var showProfileView: Bool = false
    @State private var showFullLogsView: Bool = false  // State for showing full logs view
    
    var body: some View {
        
        NavigationStack {
            VStack {
                
                Spacer() // Pushes "No check-in pending" in the middle of the screen
                
                // Conditionally show thumbs button or text based on checkinPending
                if profileViewModel.checkinPending {
                    Text("How are you doing?")
                        .font(.title2)
                        .padding()
                    HStack {
                        // Thumbs Up on the Left
                        Button(action: {
                            Task {
                                await profileViewModel.updateChildResponse(childResponse: "good")
                            }
                            print("Thumbs Up clicked")
                        }) {
                            Image(systemName: "hand.thumbsup.fill")
                                .font(.title)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .foregroundColor(.green)
                                .padding()
                        }
                        .buttonStyle(PlainButtonStyle()) // To ensure no default styling on the button
                        
                        Divider()
                            .frame(height: 40)
                            .background(Color.gray)
                        
                        // Thumbs Down on the Right
                        Button(action: {
                            Task {
                                await profileViewModel.updateChildResponse(childResponse: "bad")
                            }
                            print("Thumbs Down clicked")
                        }) {
                            Image(systemName: "hand.thumbsdown.fill")
                                .font(.title)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .foregroundColor(.red)
                                .padding()
                        }
                        .buttonStyle(PlainButtonStyle()) // To ensure no default styling on the button
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 5)
                } else {
                    // Show text when no check-in is pending
                    Spacer(minLength: 100)
                    Text("No check-in pending")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding()
                }
                
                Spacer(minLength: 125) // Add a small gap before logs
                
                // Logs section
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Recent Check-Ins")
                            .font(.title)
                            .padding(.top, 10)
                            .padding(.leading, 15)
                        
                        Spacer()
                        
                        // Button to go to the full logs
                        Button(action: {
                            showFullLogsView.toggle()
                        }) {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.title3)
                                .foregroundColor(.blue)
                                .padding(.trailing, 15)
                        }
                    }
                    
                    // Show recent logs (displaying the first few logs)
                    if childViewModel.isLoading {
                        ProgressView("Loading logs...")
                            .padding()
                    } else if let errorMessage = childViewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    } else {
                        ScrollView {
                            let recentCheckins = childViewModel.checkins.prefix(3)
                            
                            ForEach(recentCheckins, id: \.self) { checkin in
                                LogView(checkin: checkin)
                            }
                        }
                    }
                    
                    // Show a loading spinner at the bottom if more check-ins are being loaded
                    if childViewModel.isLoading {
                        ProgressView("Loading more...")
                            .padding()
                    }
                }
            }
            .navigationTitle("Welcome")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showProfileView.toggle() // Navigate to profile view
                    }) {
                        Image(systemName: "person.crop.circle") // Profile icon
                            .font(.title)
                            .foregroundColor(Color.blue) // Adjust color as needed
                    }
                }
            }
            .navigationDestination(isPresented: $showProfileView) {
                ChildProfileView()
            }
            .navigationDestination(isPresented: $showFullLogsView) {
                ChildAllLogs()
            }
        }
        .onAppear {
            Task {
                await profileViewModel.fetchUserData()
                await childViewModel.fetchCheckins()
                childViewModel.startListeningForCheckins()
                profileViewModel.startListeningForPendingStatus()
            }
        }
        .onDisappear {
            childViewModel.stopListeningForCheckins()
            profileViewModel.stopListeningForPendingStatus()
        }
    }
}

#Preview {
    ChildMainView()
}

