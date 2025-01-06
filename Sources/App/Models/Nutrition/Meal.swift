//
//  Meal.swift
//  ZakfitVapor
//
//  Created by Klesya on 05/01/2025.
//

import Vapor
import Fluent

/**
 **Documentation de la classe Meal.**
 Représente un repas spécifique, associé à un utilisateur et avec des informations sur le type de repas.
 */
final class Meal: Model, Content, @unchecked Sendable {
    // MARK: - Nom de la table
    static let schema = "meals" // Nom de la table dans la base de données
    
    // MARK: - Colonnes
    /// L'identifiant unique du repas.
    @ID(custom: "id_meal", generatedBy: .database)
    var id: UUID?
    
    /// Le nom du repas.
    @Field(key: "name_meal")
    var nameMeal: String
    
    /// Le type de repas (ex: Petit-déjeuner, Dîner).
    @Field(key: "type_of_meal")
    var typeOfMeal: String
    
    /// La quantité de ce repas.
    @Field(key: "quantity_meal")
    var quantityMeal: Double
    
    /// La date et l'heure du repas.
    @Field(key: "date_meal")
    var dateMeal: Date
    
    /// Le nombre de calories de ce repas.
    @Field(key: "calories_by_meal")
    var caloriesByMeal: Double
    
    /// L'utilisateur associé à ce repas.
    @Parent(key: "id_user")
    var user: User
    
    // MARK: - Constructeurs
    /// Constructeur par défaut requis par Fluent.
    init() { }
    
    /// Initialise un repas avec les valeurs fournies.
    ///
    /// - Parameters:
    ///   - id: L'identifiant unique du repas (facultatif).
    ///   - userId: L'identifiant de l'utilisateur qui a créé le repas.
    ///   - name: Le nom du repas.
    ///   - typeOfMeal: Le type de repas (ex: Petit-déjeuner, Dîner).
    ///   - quantity: La quantité du repas.
    ///   - date: La date et l'heure du repas.
    ///   - calories: Le nombre de calories du repas.
    init(id: UUID? = nil, nameMeal: String, typeOfMeal: String, quantityMeal: Double, dateMeal: Date, caloriesByMeal: Double, userID: UUID) {
        self.id = UUID()
        self.nameMeal = nameMeal
        self.typeOfMeal = typeOfMeal
        self.quantityMeal = quantityMeal
        self.dateMeal = dateMeal
        self.caloriesByMeal = caloriesByMeal
        self.$user.id = userID
    }
}

struct PartialMeal: Content {
    let nameMeal: String
    let typeOfMeal: String
    var quantityMeal: Double
    let dateMeal: Date
    let caloriesByMeal: Double
}
