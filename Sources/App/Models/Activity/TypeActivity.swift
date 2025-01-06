//
//  TypeActivity.swift
//  ZakfitVapor
//
//  Created by Klesya on 04/01/2025.
//

import Vapor
import Fluent

final class TypeActivity: Model, Content, @unchecked Sendable {
    
    /// Nom de la table dans base de données.
    static let schema = "type_activities"
    
    /// Identifiant unique du type d'activité (clé primaire).
    /// Ce champ est mappé à la colonne `id_type_activity` dans la base de données.
    /// - Note: La base de données gère la génération de cet identifiant si `generatedBy: .database` est utilisé.
    @ID(custom: "id_type_activity", generatedBy: .database)
    var id: UUID?
    
    /// Le prénom de l'utilisateur.
    @Field(key: "name_type_activity")
    var nameTypeActivity: String
    
    /// Initialiseur par défaut requis pour Fluent.
    init() {}
    
    /// Initialiseur personnalisé pour créer un type d'activité avec des informations spécifiques.
    init(id: UUID? = nil, nameTypeActivity: String) {
        self.id = id
        self.nameTypeActivity = nameTypeActivity
    }
}
