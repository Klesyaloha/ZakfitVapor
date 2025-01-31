//
//  UpdatePasswordRequest.swift
//  ZakfitVapor
//
//  Created by Klesya on 1/26/25.
//

import Vapor

struct UpdatePasswordRequest: Content {
    let oldPassword: String
    let newPassword: String
}
