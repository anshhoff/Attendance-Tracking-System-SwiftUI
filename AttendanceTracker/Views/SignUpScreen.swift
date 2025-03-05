//
//  SignUpScreen.swift
//  AttendanceTracker
//
//  Created by Ansh Hardaha on 2025/02/22.
//

import SwiftUI

struct SignUpScreen: View {
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var regNo: String = ""
    @State private var role: String = "Student"
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
                Button(action: {
                    if role == "Student" {
                        navigateToHomeStudent = true
                    } else {
                        navigateToHomeFaculty = true
                    }
                }) {
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

                NavigationLink(destination: LoginScreen(), isActive: $navigateToLogin) {
                    Button(action: {
                        navigateToLogin = true
                    }) {
                        Text("Already have an account? Login")
                            .foregroundColor(.blue)
                    }
                }
                .padding(.top, 8)
            }
            .padding()
        }
    }
}

// Placeholder Home Screens
struct StudentHomeScreen: View {
    var body: some View {
        Text("Student Home Screen")
            .font(.largeTitle)
    }
}


struct SignUpScreen_Previews: PreviewProvider {
    static var previews: some View {
        SignUpScreen()
    }
}
