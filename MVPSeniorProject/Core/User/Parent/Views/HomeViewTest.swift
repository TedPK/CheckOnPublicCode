//
//  HomeView.swift
//  MVPSeniorProject
//
//  Created by Family on 12/6/24.
//

import SwiftUI

struct HomeViewTest: View {
    @State private var isCheckInRequested = false
    @State private var hasResponded = false
    
    var body: some View {
        VStack {
            if isCheckInRequested && !hasResponded {
                HStack {
                    Button(action: {
                        hasResponded = true
                        // handle thumbs up action (e.g., send response to server)
                    }) {
                        Image(systemName: "hand.thumbsup.fill")
                            .font(.largeTitle)
                            .foregroundColor(.green)
                    }
                    
                    Button(action: {
                        hasResponded = true
                        // handle thumbs down action (e.g., send response to server)
                    }) {
                        Image(systemName: "hand.thumbsdown.fill")
                            .font(.largeTitle)
                            .foregroundColor(.red)
                    }
                }
            } else {
                Text("Awaiting checkin request...")
                    .font(.headline)
            }
        }
        .onAppear {
            // Simulate a check-in request from the parent after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                isCheckInRequested = true
            }
        }
    }
}

#Preview {
    HomeViewTest()
}
