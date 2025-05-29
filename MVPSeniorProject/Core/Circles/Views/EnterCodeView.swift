//
//  EnterCodeView.swift
//  MVPSeniorProject
//
//  Created by Family on 12/4/24.
//

import SwiftUI

struct EnterCodeView: View {
    
    @StateObject var viewModel = CircleViewModel()
    @State var navigateToChildView = false
    
    var body: some View {
        TextField("Enter Code", text: $viewModel.enteredCode)
            .padding(.vertical, 40)
        Button {
            Task {
                await viewModel.codeEntered()
                if viewModel.codeCorrect {
                    navigateToChildView.toggle()
                }
            }
        } label: {
            Text("Join the circle")
                .bold()
                .foregroundStyle(Color("dynamicNavyBlue"))
                .overlay(Capsule().stroke(Color("dynamicNavyBlue"), lineWidth: 5).frame(width: 360, height: 50))
        }
        .fullScreenCover(isPresented: $navigateToChildView) {
            ChildMainView()
                .navigationBarBackButtonHidden()
        }
    }
}

#Preview {
    EnterCodeView()
}
