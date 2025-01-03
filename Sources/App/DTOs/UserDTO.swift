//
//  UserDTO.swift
//  ZakfitVapor
//
//  Created by Klesya on 11/12/2024.
//

import Fluent
import Vapor

/**
    **Data Transfer Object (DTO) pour un utilisateur**
 `User DTO` transmet les infos de l'user entre le backend et le fronend de manière sécurisée et contrôlée.
    Il exclut les données sensibles comme les mots de passe.
 */

struct UserDTO: Content {
    /// L'identifiant unique de l'utilisateur.
    var id: UUID?
    
    /// Le prénom de l'utilisateur.
    var nameUser: String
    
    /// Le nom de famille de l'utilisateur.
    var surname: String
    
    /// L'adresse email de l'utilisateur.
    var email: String
    
    /// La taile de l'utilisateur en cm.
    var sizeUser: Double?
    
    /// Le poids de l'utilisateur en kg.
    var weight: Double?
    
    /// L'objectif santé de l'utilisateur :
    /// - 0 : Perte de poids
    /// - 1 : Prise de masse
    /// - 2 : Maintien
    var healthChoice: Int?
    
    /// Préférences alimentaires :
    /// - 0 : Viande
    /// - 1 : Poisson
    /// - 2 : D'origine animale
    /// - 3 : Aliments crus
    /// - 4 : Produits locaux
    /// - 5 : Gluten
    var eatChoice: [Int]?
    
    /// Initialise un `UserDTO` à partir d'une instance du modèle `User`.
    ///
    /// - Parameters:
    ///   - user: L'instance du modèle `User` provenant de la base de données.
    init(user: User) {
        self.id = user.id
        self.nameUser = user.nameUser
        self.surname = user.surname
        self.email = user.email
        self.sizeUser = user.sizeUser
        self.weight = user.weight
        self.healthChoice = user.healthChoice
        self.eatChoice = user.eatChoice
    }
}

