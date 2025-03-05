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
    @State private var passwordVisible: Bool = false
    @State private var role: String = "Student"
    @State private var navigateToSignUp = false

    var body: some View {
        NavigationStack {
            VStack {
                Text("Welcome Back!")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.bottom, 16)

                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 16)

                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 16)

                Button(action: {
                    
                    // Handle login logic here
                }) {
                    Text("Login")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 50)
                .padding(.top, 16)

                NavigationLink(destination: SignUpScreen(), isActive: $navigateToSignUp) {
                    Button(action: {
                        navigateToSignUp = true
                    }) {
                        Text("Don't have an account? Sign Up")
                            .foregroundColor(.blue)
                    }
                }
                .padding(.top, 8)
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
