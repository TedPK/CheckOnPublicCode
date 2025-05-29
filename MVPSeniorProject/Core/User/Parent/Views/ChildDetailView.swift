//
//  AdvancedChildView.swift
//  MVPSeniorProject
//
//  Created by Family on 12/28/24.
//

import SwiftUI

struct ChildDetailView: View {
    var child: User
    @StateObject var viewModel = SessionViewModel()
    @State private var presentPeriodPickerSheet = false
    @State private var sessionInProgress = false // Keep track of the session state
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Start Check-In Button
                Button(action: {
                    if sessionInProgress {
                        Task {
                            try await SessionService.shared.removeSessionRefFromParent()
                            try await SessionService.shared.deleteSessionDocument()
                            await CheckinService.shared.checkLastCheckin(child: child)
                            await UserService.shared.setPendingToFalse(child: child)
                            await MainActor.run {
                                sessionInProgress = false
                            }
                        }
                    } else {
                        presentPeriodPickerSheet.toggle()
                    }
                }) {
                    HStack {
                        Image(systemName: sessionInProgress ? "pause.circle.fill" : "play.circle.fill")
                            .font(.title2)
                        Text(sessionInProgress ? "Stop Check-In" : "Start Check-In")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(sessionInProgress ? Color.red : Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.horizontal, 16)
                
                // Child Options Section
                VStack(spacing: 10) {
                    NavigationLink(destination: DetailChildProfileView(child: child)) {
                        HStack {
                            Image(systemName: "person.circle")
                            Text("View Profile")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(8)
                    }
                    
                    NavigationLink(destination: ParentLogView(child: child)) {
                        HStack {
                            Image(systemName: "list.bullet")
                            Text("View Check-In Logs")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 16)
            }
            .navigationTitle(child.firstName)
            .navigationBarTitleDisplayMode(.large)
            .background(Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all)) // Use system background to adapt to dark mode
        }
        .onAppear {
            Task {
                do {
                    if let hasSession = try await SessionService.shared.hasSessionReference() {
                        sessionInProgress = hasSession
                    } else {
                        sessionInProgress = false // Default value if nil
                    }
                } catch {
                    print("Failed to load session state: \(error.localizedDescription)")
                }
            }
        }
        .onAppear {
            Task {
                do {
                    if let hasSession = try await SessionService.shared.hasSessionReference() {
                        sessionInProgress = hasSession
                    } else {
                        sessionInProgress = false // Default value if nil
                    }
                } catch {
                    print("Failed to load session state: \(error.localizedDescription)")
                }
            }
        }
        .sheet(isPresented: $presentPeriodPickerSheet) {
            PeriodPickerSheet(child: child, sessionInProgress: $sessionInProgress)
                .interactiveDismissDisabled()
        }
    }
}

#Preview {
    ChildDetailView(child: User.MOCK_USER)
}
