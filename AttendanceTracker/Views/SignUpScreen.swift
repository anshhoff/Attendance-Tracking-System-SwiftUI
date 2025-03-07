//
//  SignUpScreen.swift
//  AttendanceTracker
//
//  Created by Ansh Hardaha on 2025/02/22.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SignUpScreen: View {
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var regNo: String = ""
    @State private var role: String = "Student"
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var navigateToHomeStudent = false
    @State private var navigateToHomeFaculty = false
    @State private var navigateToLogin = false

    var body: some View {
        NavigationStack {
            VStack {
                Text("Welcome Aboard!")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.bottom, 16)

                TextField("Name", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 16)

                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 16)

                if role == "Student" {
                    TextField("Reg No.", text: $regNo)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal, 16)
                }

                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 16)

                // Role Selection
                VStack {
                    Text("Using As A?")
                        .font(.headline)
                        .padding(.top, 16)

                    Picker(selection: $role, label: Text("")) {
                        Text("Student").tag("Student")
                        Text("Faculty").tag("Faculty")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, 16)
                }

                // Sign Up Button
                Button(action: handleSignUp) {
                    Text("Sign Up")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 50)
                .padding(.top, 16)

                NavigationLink(destination: StudentHomeScreen(), isActive: $navigateToHomeStudent) { EmptyView() }
                NavigationLink(destination: FacultyHomeScreen(), isActive: $navigateToHomeFaculty) { EmptyView() }

                Button(action: { navigateToLogin = true }) {
                    Text("Already have an account? Login")
                        .foregroundColor(.blue)
                }
                .padding(.top, 8)
                
                NavigationLink(destination: LoginScreen(), isActive: $navigateToLogin) { EmptyView() }
            }
            .padding()
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private func handleSignUp() {
        guard !name.isEmpty, !email.isEmpty, !password.isEmpty else {
            alertMessage = "Please fill in all fields"
            showAlert = true
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                alertMessage = error.localizedDescription
                showAlert = true
                return
            }
            
            guard let user = result?.user else { return }
            
            let userData: [String: Any] = [
                "name": name,
                "email": email,
                "role": role,
                "regNo": role == "Student" ? regNo : "",
                "createdAt": Timestamp(date: Date())
            ]
            
            Firestore.firestore().collection("users")
                .document(user.uid)
                .setData(userData) { error in
                    if let error = error {
                        alertMessage = "Error saving user: \(error.localizedDescription)"
                        showAlert = true
                    } else {
                        if role == "Student" {
                            navigateToHomeStudent = true
                        } else {
                            navigateToHomeFaculty = true
                        }
                    }
                }
        }
    }
}

struct SignUpScreen_Previews: PreviewProvider {
    static var previews: some View {
        SignUpScreen()
    }
}


