//
//  CompositionController.swift
//  ZakfitVapor
//
//  Created by Klesya on 05/01/2025.
//

import Vapor
import Fluent

/// **Contrôleur pour gérer les compositions de repas (relation entre aliments et repas).**
/// Ce contrôleur permet de créer, lire et supprimer des compositions.
struct CompositionController: RouteCollection {
    
    // MARK: - Routes
    
    /// Configure les routes associées au contrôleur.
    ///
    /// - Parameter routes: Le groupe de routes auquel ce contrôleur ajoute ses routes.
    func boot(routes: RoutesBuilder) throws {
        let compositions = routes.grouped("compositions")
        let tokenProtected = compositions.grouped(JWTMiddleware())
        
        tokenProtected.post(use: self.create)          // Création d'une composition
        tokenProtected.group(":compositionID") { composition in
            composition.delete(use: self.delete)      // Suppression d'une composition
        }
    }
    
    // MARK: - Fonction POST
    
    /// **Création d'une composition (aliments dans un repas).**
    @Sendable
    func create(req: Request) async throws -> Composition {
        try req.auth.require(User.self)
        
        let input = try req.content.decode(PartialComposition.self)
        
        let newComposition = Composition(
            id: UUID(),
            foodId: input.foodId,
            mealId: input.mealId,
            quantity: input.quantity
        )
        
        try await newComposition.save(on: req.db)
        
        return newComposition
    }
    
    // MARK: - Fonction DELETE
    
    /// **Suppression d'une composition.**
    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let compositionID = req.parameters.get("compositionID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "ID de composition manquant ou invalide.")
        }
        
        guard let compositionToDelete = try await Composition.query(on: req.db).filter(\.$id == compositionID).first() else {
            throw Abort(.notFound, reason: "Composition introuvable.")
        }
        
        try await compositionToDelete.delete(on: req.db)
        
        return .noContent
    }
}
