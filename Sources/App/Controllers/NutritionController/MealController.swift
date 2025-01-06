//
//  MealController.swift
//  ZakfitVapor
//
//  Created by Klesya on 05/01/2025.
//

import Vapor
import Fluent

/// **Contrôleur pour gérer les repas.**
/// Ce contrôleur fournit des routes pour créer, lire, mettre à jour et supprimer des repas.
struct MealController: RouteCollection {
    
    // MARK: - Routes
    
    /// Configure les routes associées au contrôleur.
    ///
    /// - Parameter routes: Le groupe de routes auquel ce contrôleur ajoute ses routes.
    func boot(routes: RoutesBuilder) throws {
        let meals = routes.grouped("meals")
        let tokenProtected = meals.grouped(JWTMiddleware())
        
        tokenProtected.post(use: self.create)         // Création d'un repas
        tokenProtected.get(use: self.getAll)         // Récupération de tous les repas
        tokenProtected.get("all_meals", use: self.getAllMealsWithFood) // Récupère tous les repas d'un utilisateur avec leurs aliments associés
        tokenProtected.group(":mealID") { meal in
            meal.get(use: self.getById)              // Récupération d'un repas par ID
            meal.put(use: self.update)               // Mise à jour d'un repas
            meal.delete(use: self.delete)           // Suppression d'un repas
        }
    }
    
    // MARK: - Fonction POST
    
    /// **Création d'un repas.**
    @Sendable
    func create(req: Request) async throws -> Meal {
        // Afficher le token reçu dans l'en-tête
        if let token = req.headers[.authorization].first {
            print("Token reçu : \(token)")
        } else {
            print("Aucun token trouvé dans les en-têtes.")
        }
        
        // Vérifier que l'utilisateur est authentifié
        let user: User
        do {
            user = try req.auth.require(User.self)
            print("Utilisateur authentifié avec ID : \(String(describing: user.id))")
        } catch {
            print("Erreur d'authentification : \(error)")
            throw Abort(.unauthorized, reason: "Token invalide ou utilisateur non trouvé.")
        }
        
        let input = try req.content.decode(PartialMeal.self)
        
        let newMeal = Meal(
            nameMeal: input.nameMeal,
            typeOfMeal: input.typeOfMeal,
            quantityMeal: input.quantityMeal,
            dateMeal: input.dateMeal,
            caloriesByMeal: input.caloriesByMeal,
            userID: user.id!
        )
        
        try await newMeal.save(on: req.db)
        
        return newMeal
    }
    
    // MARK: - Fonction GET ALL
    
    /// **Récupération de tous les repas.**
    @Sendable
    func getAll(req: Request) async throws -> [Meal] {
        return try await Meal.query(on: req.db).all()
    }
    
    // MARK: - Fonction GET BY ID
    
    /// **Récupération d'un repas par son ID.**
    @Sendable
    func getById(req: Request) async throws -> Meal {
        guard let mealID = req.parameters.get("mealID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "ID de repas manquant ou invalide.")
        }
        
        guard let meal = try await Meal.query(on: req.db).filter(\.$id == mealID).first() else {
            throw Abort(.notFound, reason: "Repas introuvable.")
        }
        
        return meal
    }
    
    // MARK: - Fonction PUT
    
    /// **Mise à jour d'un repas.**
    @Sendable
    func update(req: Request) async throws -> Meal {
        guard let mealID = req.parameters.get("mealID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "ID de repas manquant ou invalide.")
        }
        
        guard let existingMeal = try await Meal.query(on: req.db).filter(\.$id == mealID).first() else {
            throw Abort(.notFound, reason: "Repas introuvable.")
        }
        
        let updatedData = try req.content.decode(Meal.self)
        
        existingMeal.nameMeal = updatedData.nameMeal
        existingMeal.typeOfMeal = updatedData.typeOfMeal
        existingMeal.quantityMeal = updatedData.quantityMeal
        existingMeal.dateMeal = updatedData.dateMeal
        existingMeal.caloriesByMeal = updatedData.caloriesByMeal
        
        try await existingMeal.save(on: req.db)
        
        return existingMeal
    }
    
    // MARK: - Fonction DELETE
    
    /// **Suppression d'un repas.**
    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let mealID = req.parameters.get("mealID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "ID de repas manquant ou invalide.")
        }
        
        guard let mealToDelete = try await Meal.query(on: req.db).filter(\.$id == mealID).first() else {
            throw Abort(.notFound, reason: "Repas introuvable.")
        }
        
        try await mealToDelete.delete(on: req.db)
        
        return .noContent
    }
    
    // Fonction pour récupérer tous les repas avec leurs aliments associés
    @Sendable
    func getAllMealsWithFood(req: Request) async throws -> [MealWithFoods] {
        // Récupère l'utilisateur authentifié
        let user = try req.auth.require(User.self)
        
        // Recherche tous les repas de cet utilisateur
        let meals = try await Meal.query(on: req.db)
            .filter(\.$user.$id == user.id!)
            .all()
        
        // Crée un tableau pour les résultats
        var mealWithFoodsList: [MealWithFoods] = []
        
        for meal in meals {
            // Pour chaque repas, récupérer les aliments associés via la table `Composition`
            let compositions = try await Composition.query(on: req.db)
                .filter(\.$meal.$id == meal.id!)
                .with(\.$food) // Récupérer les aliments liés à ce repas
                .all()
            
            // Créer un objet pour ce repas avec la liste des aliments
            let mealWithFoods = MealWithFoods(meal: meal, foods: compositions.map { $0.food })
            mealWithFoodsList.append(mealWithFoods)
        }
        
        return mealWithFoodsList
    }
}
