//
//  MVPParentMainView.swift
//  SeniorProjectApp
//
//  Created by Family on 10/12/24.
//

import SwiftUI

struct ParentMainView: View {
    
    @State var showProfileView: Bool = false
    @State public var isContactSheetPresented = false
    @State var showAddChildView: Bool = false
    @State var selectedChild: User? = nil
    @StateObject private var viewModel = ParentViewModel()
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Members") {
                    if viewModel.isLoading {
                        ProgressView("Loading...")
                    } else if viewModel.children.isEmpty {
                        Text("No members found.")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(viewModel.children, id: \.id) { child in
                            Button(child.firstName) {
                                selectedChild = child
                            } // Display each child's name
                        }
                    }
                    Button("Add Member +") {
                        showAddChildView.toggle()
                    }
                }
                .onAppear {
                    Task {
                        await viewModel.loadChildren()
                    }
                }
                
            }
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
            .navigationTitle("Your Circle")
            .navigationDestination(isPresented: $showAddChildView) {
                AddChildView()
            }
            .sheet(isPresented: $isContactSheetPresented) {
                ContactUsView()
                    .interactiveDismissDisabled()
            }
            .navigationDestination(isPresented: $showProfileView) {
                ParentProfileView()
            }
            .navigationDestination(isPresented: Binding(
                get: { selectedChild != nil },
                set: { if !$0 { selectedChild = nil } }
            )) {
                if let selectedChild = selectedChild {
                    ChildDetailView(child: selectedChild)  // Pass selected child to profile view
                }
            }
        }
    }
}

#Preview {
    ParentMainView()
}
