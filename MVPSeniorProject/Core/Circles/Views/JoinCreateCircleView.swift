//
//  JoinCreateCircle.swift
//  MVPSeniorProject
//
//  Created by Family on 12/4/24.
//

import SwiftUI

//struct JoinCreateCircleView: View {
//
//    @StateObject private var viewModel = CircleViewModel()
//    @State var navigateToParentView = false
//    @State var navigateToEnterCodeView = false
//
//    var body: some View {
//        if viewModel.isLoading {
//            ProgressView("Creating a circle...")
//        } else {
//
//                // NavigationLink for "Join a Circle"
//            Button {
//                navigateToEnterCodeView.toggle()
//            } label: {
//                Text("Join a Circle")
//                    .bold()
//                    .foregroundStyle(Color("dynamicNavyBlue"))
//                    .overlay(Capsule().stroke(Color("dynamicNavyBlue"), lineWidth: 5).frame(width: 360, height: 50))
//            }
//            .navigationDestination(isPresented: $navigateToEnterCodeView) {
//                EnterCodeView()
//            }
//
//            // NavigationLink for "Create a Circle"
//            Button {
//                Task {
//                    do {
//                        try await viewModel.createCircleTapped()
//                        navigateToParentView.toggle()
//                    } catch {
//                        print("Error creating circle(JoinCreateCircleView): \(error)")
//                    }
//                }
//            } label: {
//                Text("Create a Circle")
//                    .bold()
//                    .foregroundStyle(Color("dynamicNavyBlue"))
//                    .overlay(Capsule().stroke(Color("dynamicNavyBlue"), lineWidth: 5).frame(width: 360, height: 50))
//            }
//            .navigationDestination(isPresented: $navigateToParentView) {
//                ParentMainView()
//                    .navigationBarBackButtonHidden()
//            }
//            .padding(.vertical, 40)
//
//            // "Sign Out" button
//            Button {
//                AuthService.shared.signOut()
//            } label: {
//                Text("Sign out")
//                    .bold()
//                    .foregroundStyle(Color("dynamicNavyBlue"))
//                    .overlay(Capsule().stroke(Color("dynamicNavyBlue"), lineWidth: 5).frame(width: 360, height: 50))
//            }
//        }
//    }
//}

struct JoinCreateCircleView: View {
    
    @StateObject private var viewModel = CircleViewModel()
    @State var navigateToParentView = false
    @State var navigateToEnterCodeView = false
    
    var body: some View {
        NavigationStack {
            if viewModel.isLoading {
                ProgressView("Creating a circle...")
            } else {
                VStack {
                    // NavigationLink for "Join a Circle"
                    Button {
                        navigateToEnterCodeView.toggle()
                    } label: {
                        Text("Join a Circle")
                            .bold()
                            .foregroundStyle(Color("dynamicNavyBlue"))
                            .overlay(Capsule().stroke(Color("dynamicNavyBlue"), lineWidth: 5).frame(width: 360, height: 50))
                    }
                    .fullScreenCover(isPresented: $navigateToEnterCodeView) {
                        EnterCodeView()
                    }
                    
                    // NavigationLink for "Create a Circle"
                    Button {
                        Task {
                            do {
                                try await viewModel.createCircleTapped()
                                navigateToParentView.toggle()
                            } catch {
                                print("Error creating circle(JoinCreateCircleView): \(error)")
                            }
                        }
                    } label: {
                        Text("Create a Circle")
                            .bold()
                            .foregroundStyle(Color("dynamicNavyBlue"))
                            .overlay(Capsule().stroke(Color("dynamicNavyBlue"), lineWidth: 5).frame(width: 360, height: 50))
                    }
                    .fullScreenCover(isPresented: $navigateToParentView) {
                        ParentMainView()
                    }
//                    .navigationDestination(isPresented: $navigateToParentView) {
//                        ParentMainView()
//                            .navigationBarBackButtonHidden()
//                    }
                    .padding(.vertical, 40)
                    
                    // "Sign Out" button
                    Button {
                        AuthService.shared.signOut()
                    } label: {
                        Text("Sign out")
                            .bold()
                            .foregroundStyle(Color("dynamicNavyBlue"))
                            .overlay(Capsule().stroke(Color("dynamicNavyBlue"), lineWidth: 5).frame(width: 360, height: 50))
                    }
                }
            }
        }
    }
}

#Preview {
    JoinCreateCircleView()
}
