//
//  ContentView.swift
//  MVPSeniorProject
//
//  Created by Family on 10/13/24.
//

import SwiftUI


struct ContentView: View {
    @StateObject var viewModel = ContentViewModel()
    
    var body: some View {
        Group {
            if viewModel.userSession == nil {
                // LoginView()
                SignInView()
            } else {
                if viewModel.isLoading {
                    ProgressView("Loading...")
                } else if let role = viewModel.role {
                    switch role {
                    case .parent:
                        ParentMainView()
                    case .child:
                        ChildMainView()
                    case .noRole:
                        JoinCreateCircleView()
                    }
                } else {
                    // If for some reason the role is not determined, show JoinCreateCircleView
                    JoinCreateCircleView()
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchUserRole() // Make sure role is fetched on view appearance
            }
        }
    }
}

#Preview {
    ContentView()
}
