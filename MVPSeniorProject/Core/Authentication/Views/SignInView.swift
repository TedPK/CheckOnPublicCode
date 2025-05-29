//
//  SignInWithGoogleLoginScreen.swift
//  MVPSeniorProject
//
//  Created by Family on 4/25/25.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift
import AuthenticationServices

struct SignInView: View {
    
    @StateObject var loginViewModel = LoginViewModel()
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            // Oversized and rotated pattern to fill even the corners
            GeometryReader { geo in
                BackgroundPattern()
                    .frame(width: geo.size.width * 1.5, height: geo.size.height * 1.5)
                    .rotationEffect(.degrees(15))
                    .opacity(0.06)
                    .position(x: geo.size.width / 2, y: geo.size.height / 2)
            }
            .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                Text("Welcome to Check-On")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Constants.navyBlue)
                    .padding(.bottom, 40)
                
                GoogleSignInButton {
                    Task {
                        await loginViewModel.signInWithGoogle()
                    }
                }
                .frame(height: 50)
                .clipShape(Capsule())
                .padding(.horizontal, 40)
                
                SignInWithAppleButton(
                    .signIn,
                    onRequest: { request in
                        loginViewModel.signInWithAppleRequest(request: request)
                    },
                    onCompletion: { result in
                        Task {
                            await loginViewModel.signInWithAppleCompletion(result: result)
                        }
                    }
                )
                .signInWithAppleButtonStyle(.black)
                .frame(height: 50)
                .clipShape(Capsule())
                .padding(.horizontal, 40)
                .padding(.top, 12)
                
                Spacer()
                
                
                
                HStack(spacing: 2) {
                    Text("By continuing, you agree to our")
                        .font(.footnote)
                        .foregroundColor(.gray)
                    
                    Link("Terms and Conditions", destination: URL(string: "https://docs.google.com/document/d/1MTLLWLYD2zzZQJdgugm7v1Sp-KrZSNv6L7-xJVfNXwM/edit?tab=t.0")!)
                        .font(.footnote)
                        .foregroundColor(.blue)
                        .underline()
                }
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
    }
}

// Subtle repeated thumbs pattern
struct BackgroundPattern: View {
    let symbols = ["hand.thumbsup.fill", "hand.thumbsdown.fill"]
    
    var body: some View {
        GeometryReader { geo in
            let rows = Int(geo.size.height / 40)
            let columns = Int(geo.size.width / 40)
            
            VStack(spacing: 20) {
                ForEach(0..<rows, id: \.self) { row in
                    HStack(spacing: 20) {
                        ForEach(0..<columns, id: \.self) { col in
                            Image(systemName: symbols[(row + col) % symbols.count])
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 14, height: 14)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

#Preview {
    SignInView()
}
