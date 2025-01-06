//
//  Food.swift
//  ZakfitVapor
//
//  Created by Klesya on 05/01/2025.
//

import Vapor
import Fluent

/**
 **Documentation de la classe Food.**
 Représente un aliment spécifique avec des informations nutritionnelles.
 */
final class Food: Model, Content, @unchecked Sendable {
    // MARK: - Nom de la table
    static let schema = "foods" // Nom de la table dans la base de données
    
    // MARK: - Colonnes
    /// L'identifiant unique de l'aliment.
    @ID(custom: "id_food", generatedBy: .database)
    var id: UUID?
    
    /// Le nom de l'aliment.
    @Field(key: "name_food")
    var nameFood: String
    
    /// La quantité de l'aliment.
    @Field(key: "quantity_food")
    var quantityFood: Double
    
    /// La quantité de protéines (en grammes).
    @Field(key: "proteins")
    var proteins: Double
    
    /// La quantité de glucides (en grammes).
    @Field(key: "carbs")
    var carbs: Double
    
    /// La quantité de graisses (en grammes).
    @Field(key: "fats")
    var fats: Double
    
    /// Le nombre de calories par unité de cet aliment.
    @Field(key: "calories_by_food")
    var caloriesByFood: Double
    
    // MARK: - Constructeurs
    /// Constructeur par défaut requis par Fluent.
    init() { }

    /// Initialise un aliment avec les valeurs fournies.
    ///
    /// - Parameters:
    ///   - id: L'identifiant unique de l'aliment (facultatif).
    ///   - name: Le nom de l'aliment.
    ///   - quantity: La quantité de l'aliment.
    ///   - proteins: La quantité de protéines.
    ///   - carbs: La quantité de glucides.
    ///   - fats: La quantité de graisses.
    ///   - calories: Le nombre de calories.
    init(id: UUID? = nil, nameFood: String, quantityFood: Double, proteins: Double, carbs: Double, fats: Double, caloriesByFood: Double) {
        self.id = UUID()
        self.nameFood = nameFood
        self.quantityFood = quantityFood
        self.proteins = proteins
        self.carbs = carbs
        self.fats = fats
        self.caloriesByFood = caloriesByFood
    }
}
