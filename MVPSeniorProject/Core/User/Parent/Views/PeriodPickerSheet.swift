//
//  PeriodPickerView.swift
//  MVPSeniorProject
//
//  Created by Family on 12/28/24.
//

import SwiftUI

struct PeriodPickerSheet: View {
    var child: User
    @StateObject var viewModel = SessionViewModel()
    @State var selectedPeriod: Int = 15
    @Environment(\.dismiss) var dismiss
    @Binding var sessionInProgress: Bool  // Binding to track session state
    let periods = [5, 10, 15, 30, 60, 120, 180]
    @State var checkinPeriod: Int = 15

    var body: some View {
        NavigationView {
            VStack {
                Picker("Check-In Period (minutes)", selection: $checkinPeriod) {
                    ForEach(periods, id: \.self) { period in
                        Text("\(period) minutes").tag(period)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .padding()
            }
            .navigationTitle("Set Check-In Period")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button("Cancel") {
                dismiss()
            }, trailing: Button("Confirm") {
                Task {
                    viewModel.interval = checkinPeriod
                    guard let childId = child.uid else { return }
                    try await viewModel.createCheckinSession(childId: childId)
                    try await viewModel.updateSessionReferenceInParent()
                    
                    // Update session state to reflect that a session has started
                    sessionInProgress = true
                }
                dismiss()
            })
        }
    }
}

//#Preview {
//    PeriodPickerSheet(child: User.MOCK_USER)
//}
#Preview {
    // Create a @State variable for sessionInProgress
    ChildDetailView(child: User.MOCK_USER)
        .environmentObject(SessionViewModel())  // Use any other dependencies you might need
}
