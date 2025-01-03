//
//  PartialUserUpdate.swift
//  ZakfitVapor
//
//  Created by Klesya on 16/12/2024.
//

import Vapor

struct PartialUserUpdate: Content {
    var idUser: UUID?
    var nameUser: String?
    var surname: String?
    var email: String?
    var password: String?
    var sizeUser: Double?
    var weight: Double?
    var healthChoice: Int?
    var eatChoice: [Int]?
}
