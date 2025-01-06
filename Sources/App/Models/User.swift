//
//  User.swift
//  ZakfitVapor
//
//  Created by Klesya on 11/12/2024.
//

import Vapor
import Fluent


/**
    **Documentation de la classe User.**
    Cette classe définit un modèle utilisateur.
    Elle est utilisée pour interagir avec la base de données via le framework **Fluent**.
 */
final class User: Model, Content, @unchecked Sendable {
    
    // MARK: - Nom de la table
    
    /// Nom de la table dans base de données.
    static let schema = "users"
    
    // MARK: - Colonnes
    
    /// Identifiant unique de l'utilisatreur (clé primaire).
    /// Ce champ est mappé à la colonne `id_user` dans la base de données.
    /// - Note: La base de données gère la génération de cet identifiant si `generatedBy: .database` est utilisé.
    @ID(custom: "id_user", generatedBy: .database)
    var id: UUID?
    
    /// Le prénom de l'utilisateur.
    @Field(key: "name_user")
    var nameUser: String
    
    /// Le nom de famille de l'utilisateur.
    @Field(key: "surname")
    var surname: String
    
    /// L'adresse email de l'utilisateur.
    @Field(key: "email")
    var email: String
    
    /// Le mot de passe de l'utilisateur (doit être crypté en production).
    @Field(key: "password")
    var password: String
    
    /// La taille de l'utilisateur (en cm).
    @Field(key: "size_user")
    var sizeUser: Double?
    
    /// Le poids de l'utilisateur (en kg).
    @Field(key: "weight")
    var weight: Double?

    /// L'objectif santé de l'utilisateur :
    /// - 0 : Perte de poids
    /// - 1 : Prise de masse
    /// - 2 : Maintien
    @Field(key: "health_choice")
    var healthChoice: Int?
    
    /// Préférences alimentaires :
    /// - 0 : Viande
    /// - 1 : Poisson
    /// - 2 : D'origine animale
    /// - 3 : Aliments crus
    /// - 4 : Produits locaux
    /// - 5 : Gluten
    @Field(key: "eat_choice")
    var eatChoice: [Int]?
    
    // MARK: - Constructeurs
    
    /// Initialiseur par défaut requis pour Fluent.
    init() {}
    
    /// Initialiseur personnalisé pour créer un utilisateur avec des informations spécifiques.
    init(id: UUID? = nil, nameUser: String, surname: String, email: String, password: String, sizeUser: Double? = nil, weight: Double? = nil, healthChoice: Int? = nil, eatChoice: [Int]? = []) {
        self.id = id
        self.nameUser = nameUser
        self.surname = surname
        self.email = email
        self.password = password
        self.sizeUser = sizeUser
        self.weight = weight
        self.healthChoice = healthChoice
        self.eatChoice = eatChoice
    }
    
    // MARK: - Fonctions

    /// Conversion de l'utilisateur en `UserDTO`, un objet de transfert de données.
    ///
    /// Cette méthode permet de transformer un utilisateur en un format DTO (Data Transfer Object),
    /// utile pour envoyer les données via les API tout en excluant certaines données sensibles.
    ///
    /// - Returns: Un objet `UserDTO` qui contient les informations de l'utilisateur sous un format simplifié.
    func toDTO() -> UserDTO {
        UserDTO(user: User(nameUser: nameUser, surname: surname, email: email, password: password, sizeUser: sizeUser, weight: weight, healthChoice: healthChoice, eatChoice: eatChoice))
    }
}
