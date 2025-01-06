//
//  Composition.swift
//  ZakfitVapor
//
//  Created by Klesya on 05/01/2025.
//

import Vapor
import Fluent

/**
 **Documentation de la classe Composition.**
 Représente une relation entre un repas et un aliment spécifique, avec la quantité d'aliment dans le repas.
 */
final class Composition: Model, Content, @unchecked Sendable {
    // MARK: - Nom de la table
    static let schema = "compositions" // Nom de la table dans la base de données
    
    // MARK: - Colonnes
    /// L'identifiant de la composition.
    @ID(custom: "id", generatedBy: .database)
    var id: UUID?
    
    /// La quantité de cet aliment dans le repas.
    @Field(key: "quantity")
    var quantity: Double
    
    /// L'aliment associé à cette composition.
    @Parent(key: "id_food")
    var food: Food
    
    /// Le repas associé à cette composition.
    @Parent(key: "id_meal")
    var meal: Meal
    
    // MARK: - Constructeurs
    /// Constructeur par défaut requis par Fluent.
    init() { }
    
    /// Initialise une composition avec les valeurs fournies.
    ///
    /// - Parameters:
    ///   - id: L'identifiant unique de la composition (facultatif).
    ///   - foodId: L'identifiant de l'aliment.
    ///   - mealId: L'identifiant du repas.
    ///   - quantity: La quantité de l'aliment dans le repas.
    init(id: UUID? = nil, foodId: UUID, mealId: UUID, quantity: Double) {
        self.id = UUID()
        self.$food.id = foodId
        self.$meal.id = mealId
        self.quantity = quantity
    }
}

struct PartialComposition: Content {
    let foodId: UUID
    let mealId: UUID
    var quantity: Double
}
