//
//  FoodController.swift
//  ZakfitVapor
//
//  Created by Klesya on 05/01/2025.
//

import Vapor
import Fluent

/// **Contrôleur pour gérer les aliments.**
/// Ce contrôleur fournit des routes pour créer, lire, mettre à jour et supprimer des aliments.
struct FoodController: RouteCollection {
    
    // MARK: - Routes
    
    /// Configure les routes associées au contrôleur.
    ///
    /// - Parameter routes: Le groupe de routes auquel ce contrôleur ajoute ses routes.
    func boot(routes: RoutesBuilder) throws {
        let foods = routes.grouped("foods")
        let tokenProtected = foods.grouped(JWTMiddleware())
        
        tokenProtected.post(use: self.create)          // Création d'un aliment
        tokenProtected.get(use: self.getAll)          // Récupération de tous les aliments
        tokenProtected.group(":foodID") { food in
            food.get(use: self.getById)               // Récupération d'un aliment par ID
            food.put(use: self.update)                // Mise à jour d'un aliment
            food.delete(use: self.delete)            // Suppression d'un aliment
        }
    }
    
    // MARK: - Fonction POST
    
    /// **Création d'un nouvel aliment.**
    @Sendable
    func create(req: Request) async throws -> Food {
        // Afficher le token reçu dans l'en-tête
        if let token = req.headers[.authorization].first {
            print("Token reçu : \(token)")
        } else {
            print("Aucun token trouvé dans les en-têtes.")
        }
        
        // Vérifier l'utilisateur authentifié
        let user: User
        do {
            user = try req.auth.require(User.self)
            print("Utilisateur authentifié avec ID : \(String(describing: user.id))")
        } catch {
            print("Erreur d'authentification : \(error)")
            throw Abort(.unauthorized, reason: "Token invalide ou utilisateur non trouvé.")
        }
        
        // Décoder les données de l'aliment
        let input = try req.content.decode(Food.self)
        
        let newFood = Food(
            nameFood: input.nameFood,
            quantityFood: input.quantityFood,
            proteins: input.proteins,
            carbs: input.carbs,
            fats: input.fats,
            caloriesByFood: input.caloriesByFood
        )
        
        // Sauvegarder dans la base de données
        try await newFood.save(on: req.db)
        
        return newFood
    }
    
    // MARK: - Fonction GET ALL
    
    /// **Récupération de tous les aliments.**
    @Sendable
    func getAll(req: Request) async throws -> [Food] {
        if let token = req.headers[.authorization].first {
            print("Token reçu : \(token)")
        } else {
            print("Aucun token trouvé dans les en-têtes.")
        }
        
        // Vérifier l'utilisateur authentifié
        let user: User
        do {
            user = try req.auth.require(User.self)
            print("Utilisateur authentifié avec ID : \(String(describing: user.id))")
        } catch {
            print("Erreur d'authentification : \(error)")
            throw Abort(.unauthorized, reason: "Token invalide ou utilisateur non trouvé.")
        }
        return try await Food.query(on: req.db).all()
    }
    
    // MARK: - Fonction GET BY ID
    
    /// **Récupération d'un aliment par son ID.**
    @Sendable
    func getById(req: Request) async throws -> Food {
        guard let foodID = req.parameters.get("foodID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "ID d'aliment manquant ou invalide.")
        }
        
        guard let food = try await Food.query(on: req.db).filter(\.$id == foodID).first() else {
            throw Abort(.notFound, reason: "Aliment introuvable.")
        }
        
        return food
    }
    
    // MARK: - Fonction PUT
    
    /// **Mise à jour d'un aliment.**
    @Sendable
    func update(req: Request) async throws -> Food {
        guard let foodID = req.parameters.get("foodID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "ID d'aliment manquant ou invalide.")
        }
        
        guard let existingFood = try await Food.query(on: req.db).filter(\.$id == foodID).first() else {
            throw Abort(.notFound, reason: "Aliment introuvable.")
        }
        
        let updatedData = try req.content.decode(Food.self)
        
        existingFood.nameFood = updatedData.nameFood
        existingFood.quantityFood = updatedData.quantityFood
        existingFood.proteins = updatedData.proteins
        existingFood.carbs = updatedData.carbs
        existingFood.fats = updatedData.fats
        existingFood.caloriesByFood = updatedData.caloriesByFood
        
        try await existingFood.save(on: req.db)
        
        return existingFood
    }
    
    // MARK: - Fonction DELETE
    
    /// **Suppression d'un aliment.**
    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let foodID = req.parameters.get("foodID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "ID d'aliment manquant ou invalide.")
        }
        
        guard let foodToDelete = try await Food.query(on: req.db).filter(\.$id == foodID).first() else {
            throw Abort(.notFound, reason: "Aliment introuvable.")
        }
        
        try await foodToDelete.delete(on: req.db)
        
        return .noContent
    }
}
