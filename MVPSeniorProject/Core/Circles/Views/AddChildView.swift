//
//  AddChildView.swift
//  MVPSeniorProject
//
//  Created by Family on 12/26/24.
//

import SwiftUI

struct AddChildView: View {
    
    @StateObject var viewModel = CircleViewModel()
    
    var body: some View {
        Text("\(viewModel.currentJoinCode)")
        
        ShareLink(item: viewModel.currentJoinCode) {
            Text("Share Join Code")
                .font(.title)
                .foregroundColor(.blue)
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 2))
        }
        .onAppear() {
            Task {
                await viewModel.updateJoinCode()
            }
        
//        Button(action: {
//            print("Button was tapped!")
//        }) {
//            Text("Share")
//                .font(.title)
//                .padding()
//                .background(Color.blue)
//                .foregroundColor(.white)
//                .cornerRadius(10)
//        }
        }
    }
}

#Preview {
    AddChildView()
}
