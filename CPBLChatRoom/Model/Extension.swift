//
//  Extension.swift
//  CPBLChatRoom
//
//  Created by 林靖芳 on 2024/8/9.
//

import Foundation
import SwiftUI

extension Encodable {
    func asDictionary() -> [String : Any] {
        
        //把資料編碼，失敗回傳空字典
        guard let data = try? JSONEncoder().encode(self) else {
            return [:]
        }
        do {
            let json = try JSONSerialization.jsonObject(with: data) as? [String:Any]
            return json ?? [:]
        } catch {
            return [:]
        }
    }
}


extension View {
    
    func standardTextField(radius: CGFloat = 5) -> some View {
        autocapitalization(.none)
        .autocorrectionDisabled()
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(radius)
        
    }
    
    func standardFieldTextTitle(width: CGFloat = 100, textColor: Color) -> some View {
        frame(width: width)
        .foregroundStyle(textColor)
    }
}


extension TextField where Label == Text {
    func loginFieldFocus(_ field: FocusState<LoginField?>.Binding, equals this: LoginField) -> some View {
        submitLabel(this == .password ? .done : .next)
        .focused(field, equals: this)
        .onSubmit {
            field.wrappedValue = this == .password ? nil : .init(rawValue: this.rawValue + 1)
        }
    }
    
    func registerFieldFocus(_ field: FocusState<RegisterField?>.Binding, equals this: RegisterField) -> some View {
        submitLabel(this == .password ? .done : .next)
        .focused(field, equals: this)
        .onSubmit {
            field.wrappedValue = this == .password ? nil : .init(rawValue: this.rawValue + 1)
        }
    }
    
    
}


extension SecureField where Label == Text {
   func loginSecureFieldFocus(_ field: FocusState<LoginField?>.Binding, equals this: LoginField) -> some View {
        submitLabel(this == .password ? .done : .next)
        .focused(field, equals: this)
        .onSubmit {
            field.wrappedValue = this == .password ? nil : .init(rawValue: this.rawValue + 1)
        }
    }
    
    func registerSecureFieldFocus(_ field: FocusState<RegisterField?>.Binding, equals this: RegisterField) -> some View {
        frame(maxWidth: .infinity)
            .submitLabel(this == .password ? .done : .next)
         .focused(field, equals: this)
         .onSubmit {
             field.wrappedValue = this == .password ? nil : .init(rawValue: this.rawValue + 1)
         }
     }
}


