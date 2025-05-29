//
//  DetailChildProfileView.swift
//  MVPSeniorProject
//
//  Created by Family on 12/28/24.
//

import SwiftUI

struct DetailChildProfileView: View {
    
    var child: User
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Email") {
                    Text("\(child.email)")
                }
                Button {
                    //idk
                } label: {
                    Text("Remove from circle")
                        .foregroundStyle(.red)
                }

            }
            .navigationTitle("\(child.firstName)")
        }
    }
}

#Preview {
    DetailChildProfileView(child: User.MOCK_USER)
}
