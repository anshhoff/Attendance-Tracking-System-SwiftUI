//
//  LoginScreen.swift
//  AttendanceTracker
//
//  Created by Ansh Hardaha on 2025/02/22.
//

import SwiftUI

struct LoginScreen: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var role: String = "Student"
    @State private var showPassword: Bool = false
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
                    
                    // Role Selection
                    Picker("Select Role", selection: $role) {
                        Text("Student").tag("Student")
                        Text("Faculty").tag("Faculty")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, 16)
                }
                
                // Login Button
                Button(action: {
                    if role == "Student" {
                        navigateToStudentHome = true
                    } else {
                        navigateToFacultyHome = true
                    }
                }) {
                    Text("Login")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 50)
                .padding(.top, 32)
                
                // Navigation Links
                NavigationLink(destination: StudentHomeScreen(), isActive: $navigateToStudentHome) { EmptyView() }
                NavigationLink(destination: FacultyHomeScreen(), isActive: $navigateToFacultyHome) { EmptyView() }
                
                // Sign Up Link
                Button(action: { navigateToSignUp = true }) {
                    Text("Don't have an account? Sign Up")
                        .foregroundColor(.blue)
                }
                .padding(.top, 16)
                
                NavigationLink(destination: SignUpScreen(), isActive: $navigateToSignUp) { EmptyView() }
            }
            .padding()
        }
    }
}

struct LoginScreen_Previews: PreviewProvider {
    static var previews: some View {
        LoginScreen()
    }
}
