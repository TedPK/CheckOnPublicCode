// ContentViewModel.swift


import Firebase
import Combine
import FirebaseAuth

class ContentViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User? = Auth.auth().currentUser
    @Published var role: User.Role? = nil
    @Published var isLoading = true
    
    private var cancellables = Set<AnyCancellable>()
    private var circleViewModel = CircleViewModel()
    
    init() {
        setupSubscribers()
    }
    
    private func setupSubscribers() {
        // This is subscribing to changes in AuthService's userSession and handling them
        AuthService.shared.$userSession
            .receive(on: DispatchQueue.main)  // Ensures updates happen on the main thread
            .sink { [weak self] userSession in
                self?.userSession = userSession
                Task {
                    await self?.fetchUserRole()
                }
            }
            .store(in: &cancellables)
    }
    
    @MainActor
    func fetchUserRole() async {
        guard userSession != nil else {
            // If no user session, mark loading as false and return
            isLoading = false
            return
        }
        
        Task {
            if let userRole = await CircleService.shared.getUserRole() {
                print("Fetched user role: \(userRole)")  // Add debug print statement
                await MainActor.run { [weak self] in
                    self?.role = userRole
                }
            } else {
                await MainActor.run { [weak self] in
                    self?.role = .noRole
                }
            }
            
            // Mark loading as false on the main thread
            await MainActor.run { [weak self] in
                self?.isLoading = false
            }
        }
    }
}
