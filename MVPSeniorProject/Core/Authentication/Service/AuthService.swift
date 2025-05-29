//
//  AuthService.swift
//  SeniorProjectApp
//
//  Created by Family on 10/12/24.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseFunctions
import FirebaseMessaging
import GoogleSignIn
import GoogleSignInSwift
import CryptoKit
import AuthenticationServices

class AuthService {
    
    @Published var userSession: FirebaseAuth.User?
    private var currentNonce: String?
    
    static let shared = AuthService()
    
    init() {
        self.userSession = Auth.auth().currentUser // gives temporary id
        
        loadCurrentUserData()
        
        //        print("DEBUG: User session id is \(userSession?.uid)")
    }
    
    @MainActor
    func login(withEmail email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            loadCurrentUserData()
            
            // Save FCM token after successful login
            if let fcmToken = Messaging.messaging().fcmToken {
                AppDelegate.shared.saveFcmTokenToFirestore(fcmToken)
            }
            
        } catch {
            print("DEBUG: Failed to sign user in with error \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func createUser(withEmail email: String, password: String, firstName: String, lastName: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            try await self.uploadUserData(email: email, firstName: firstName, lastName: lastName, uid: result.user.uid)
            loadCurrentUserData()
            
            // Save FCM token after successful user creation
            if let fcmToken = Messaging.messaging().fcmToken {
                AppDelegate.shared.saveFcmTokenToFirestore(fcmToken)
            }
            
        } catch {
            print("DEBUG: Failed to create user with error: \(error.localizedDescription)")
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut() // signs out on backend
            self.userSession = nil // signs out on frontend, updating screen to loginView // updates routing logic
            UserService.shared.currentUser = nil
        } catch {
            print("DEBUG: Failed to sign out with error \(error.localizedDescription)")
        }
    }
    
    private func uploadUserData(email: String, firstName: String, lastName: String, uid: String) async throws {
        let user = User(firstName: firstName, email: email, lastName: lastName, id: uid, role: .noRole, circleReference: nil, checkinPending: false, checkins: nil, fcmToken: nil, checkinSessionReference: nil)
        guard let encodedUser = try? Firestore.Encoder().encode(user) else { return }
        try await Firestore.firestore().collection("users").document(uid).setData(encodedUser)
    }
    
    private func loadCurrentUserData() {
        Task { try await UserService.shared.fetchCurrentUser() }
    }
    
    
    func parentDeleteAccount() async {
        // Step 1: Close the circle and update related users
        await CircleService.shared.parentCloseCircle()
        
        // Step 2: Ensure user session and user email exist
        guard let user = Auth.auth().currentUser else {
            print("No authenticated user or email found!")
            return
        }
        
        do {

            let userRef = Firestore.firestore().collection("users").document(user.uid)
            try await userRef.delete()

            try await user.delete()
            print("User account successfully deleted!")

            try Auth.auth().signOut()
            print("User successfully signed out!")
            
        } catch {
            print("Error deleting parent account: \(error.localizedDescription)")
        }
    }
    
//    func childDeleteAccount() async {
//        // Step 1: Ensure the child leaves the circle first
//        await CircleService.shared.childLeaveCircle()
//        
//        // Step 2: Ensure user session exists
//        guard let userId = userSession?.uid else {
//            print("No authenticated user found!")
//            return
//        }
//        
//        do {
//            // Step 3: Delete the user document from Firestore
//            let userRef = Firestore.firestore().collection("users").document(userId)
//            try await userRef.delete()
//            
//            // Step 4: Delete the user account from Firebase Auth
//            try await Auth.auth().currentUser?.delete()
//            
//            // Step 5: Optionally, sign out the user after deletion
//            try Auth.auth().signOut()
//            
//            print("User account successfully deleted and signed out!")
//            
//        } catch {
//            // Handling any errors that occur during the process
//            print("Error during child account deletion: \(error.localizedDescription)")
//        }
//    }
    
    
    func childDeleteAccount() async {
        
        guard let userId = userSession?.uid else {
            print("No authenticated user found!")
            return
        }
        // Step 1: Ensure the child leaves the circle first
        await CircleService.shared.childLeaveCircle()
        
        // Step 2: Ensure user session exists
        guard let user = Auth.auth().currentUser else {
            print("No authenticated user or email found!")
            return
        }
        
        do {

            
            let userRef = Firestore.firestore().collection("users").document(userId)
            try await userRef.delete()
            
            try await user.delete()
            try Auth.auth().signOut()
            
            print("User account successfully deleted and signed out!")
            
        } catch {
            print("Error during child account deletion: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func signInWithGoogle() async {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("Missing Google Client ID")
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            print("Unable to access rootViewController")
            return
        }
        
        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            
            guard let idToken = result.user.idToken?.tokenString else {
                print("Missing ID token")
                return
            }
            
            let accessToken = result.user.accessToken.tokenString
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            let authResult = try await Auth.auth().signIn(with: credential)
            
            self.userSession = authResult.user
            
            // OPTIONAL: Upload new user to Firestore if they’re new
            let isNewUser = authResult.additionalUserInfo?.isNewUser ?? false
            if isNewUser {
                try await uploadUserData(
                    email: authResult.user.email ?? "",
                    firstName: result.user.profile?.givenName ?? "First",
                    lastName: result.user.profile?.familyName ?? "Last",
                    uid: authResult.user.uid
                )
            }
            
            loadCurrentUserData()
            
            // Save FCM token
            if let fcmToken = Messaging.messaging().fcmToken {
                AppDelegate.shared.saveFcmTokenToFirestore(fcmToken)
            }
            
        } catch {
            print("Google Sign-In error: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func signInWithAppleRequest(request: ASAuthorizationAppleIDRequest) {
        let nonce = randomNonceString() // Now calls the instance method
        currentNonce = nonce
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce) // Now calls the instance method
    }

    @MainActor
    func signInWithAppleCompletion(result: Result<ASAuthorization, Error>) async {
        switch result {
        case .success(let auth):
            guard let appleIDCredential = auth.credential as? ASAuthorizationAppleIDCredential else {
                print("DEBUG: Apple ID Credential error")
                return
            }

            guard let appleIDToken = appleIDCredential.identityToken else {
                print("DEBUG: Unable to fetch identity token")
                return
            }

            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("DEBUG: Unable to decode identity token")
                return
            }

            // Ensure currentNonce is not nil before proceeding
            guard let nonce = currentNonce else {
                fatalError("Invalid nonce state: currentNonce was not set during ASAuthorizationAppleIDRequest.")
            }
            
            let credential = OAuthProvider.credential(
                providerID: .apple,
                idToken: idTokenString,
                rawNonce: nonce
            )
            
            do {
                let authResult = try await Auth.auth().signIn(with: credential)
                self.userSession = authResult.user

                // Check if user is new and upload data if needed
                let isNewUser = authResult.additionalUserInfo?.isNewUser ?? false
                if isNewUser {
                    let email = appleIDCredential.email ?? authResult.user.email ?? ""
                    let firstName = appleIDCredential.fullName?.givenName ?? "First"
                    let lastName = appleIDCredential.fullName?.familyName ?? "Last"

                    try await uploadUserData(email: email, firstName: firstName, lastName: lastName, uid: authResult.user.uid)
                }

                loadCurrentUserData()

                if let fcmToken = Messaging.messaging().fcmToken {
                    AppDelegate.shared.saveFcmTokenToFirestore(fcmToken)
                }

            } catch {
                print("DEBUG: Firebase authentication error: \(error.localizedDescription)")
            }

        case .failure(let error):
            print("DEBUG: Sign in with Apple failed: \(error.localizedDescription)")
        }
    }


    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            // It's generally better to log and return an empty string or handle gracefully
            // in a shipping app rather than fatalError, but for debugging, this is fine.
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }

        let charset: [Character] =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._")

        let nonce = randomBytes.map { byte in
            // Pick a random character from the set, with a slight preference for the lower ASCII range.
            charset[Int(byte) % charset.count]
        }

        return String(nonce)
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()

        return hashString
    }
}
