//
//  LoginResponse.swift
//  ZakfitVapor
//
//  Created by Klesya on 16/12/2024.
//
import Vapor

struct LoginResponse: Content {
    let token: String
    let user: UserDTO
    
    init(token: String, user: User) {
        self.token = token
        self.user = UserDTO(user: user) // Utilisation du constructeur de UserDTO
    }
}
