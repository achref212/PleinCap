//
//  AuthTextField.swift
//  PFE_APP
//
//  Created by chaabani achref on 22/5/2025.
//

import SwiftUI

struct AuthTextField: View {
    var placeholder: String
    @Binding var text: String
    var isSecure = false
    var keyboard: UIKeyboardType = .default
    
    var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboard)
                    .autocapitalization(.none)
            }
        }
        .padding()
        .background(BrandColors.fieldBg)
        .cornerRadius(10)
    }
}

struct AuthTextField_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 12) {
            AuthTextField(placeholder: "Email", text: .constant("john@example.com"), keyboard: .emailAddress)
            AuthTextField(placeholder: "Mot de passe", text: .constant("secret"), isSecure: true)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
