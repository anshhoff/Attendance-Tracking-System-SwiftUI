import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct LoginScreen: View {
    @State private var email: String = "faculty@gmail.com"
    @State private var password: String = "123456"
    @State private var showPassword: Bool = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var navigateToStudentHome = false
    @State private var navigateToFacultyHome = false
    @State private var navigateToSignUp = false
    
    var body: some View {
        NavigationStack {
            VStack {
                // Welcome Section with Icon
                VStack(spacing: 8) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Welcome Back!")
                        .font(.title)
                        .fontWeight(.bold)
                }
                .padding(.bottom, 32)
                
                // Login Form
                VStack(spacing: 16) {
                    // Email Field
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .padding(.horizontal, 16)
                    
                    // Password Field with Show/Hide
                    HStack {
                        if showPassword {
                            TextField("Password", text: $password)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        } else {
                            SecureField("Password", text: $password)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        Button(action: { showPassword.toggle() }) {
                            Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                
                // Login Button
                Button(action: handleLogin) {
                    Text("Login")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 50)
                .padding(.top, 32)
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
                
                // Sign Up Link
                Button(action: { navigateToSignUp = true }) {
                    Text("Don't have an account? Sign Up")
                        .foregroundColor(.blue)
                }
                .padding(.top, 16)
                
                NavigationLink(destination: SignUpScreen(), isActive: $navigateToSignUp) { EmptyView() }
                
                // Navigation Links
                NavigationLink(destination: StudentHomeScreen(), isActive: $navigateToStudentHome) { EmptyView() }
                NavigationLink(destination: FacultyHomeScreen(), isActive: $navigateToFacultyHome) { EmptyView() }
            }
            .padding()
        }
    }
    
    private func handleLogin() {
        guard !email.isEmpty, !password.isEmpty else {
            alertMessage = "Please fill in all fields"
            showAlert = true
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                alertMessage = error.localizedDescription
                showAlert = true
                return
            }
            
            guard let user = result?.user else { return }
            
            self.fetchUserRole(user)
        }
    }
    
    private func fetchUserRole(_ user: User) {
        Firestore.firestore().collection("users")
            .document(user.uid)
            .getDocument { document, error in
                if let document = document, document.exists {
                    let role = document.get("role") as? String ?? "Student"
                    DispatchQueue.main.async {
                        if role == "Student" {
                            self.navigateToStudentHome = true
                        } else {
                            self.navigateToFacultyHome = true
                        }
                    }
                } else {
                    alertMessage = "User role not found"
                    showAlert = true
                }
            }
    }
}

struct LoginScreen_Previews: PreviewProvider {
    static var previews: some View {
        LoginScreen()
    }
}
