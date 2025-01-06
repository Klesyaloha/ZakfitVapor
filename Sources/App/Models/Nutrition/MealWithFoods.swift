//
//  MealWithFoods.swift
//  ZakfitVapor
//
//  Created by Klesya on 06/01/2025.
//

import Vapor

// Modèle pour représenter un repas avec ses aliments associés
struct MealWithFoods: Content {
    var id = UUID()
    var meal: Meal
    var foods: [Food] // Liste des aliments associés à ce repas
}
