//
//  TypeActivityController.swift
//  ZakfitVapor
//
//  Created by Klesya on 04/01/2025.
//

import Fluent
import Vapor

/**
    **Contrôleur pour gérer les types d'activités physiques.**
    Ce contrôleur fournit des routes pour créer, lire, mettre à jour et supprimer des types d'activités physiques.
 */
struct TypeActivityController : RouteCollection {
    // MARK: - Routes
    /// **Fonction qui configure les routes du contrôleur.**
    /// Elle groupe les routes sous `/type_activities` et s'assure que l'accès est protégé par un token valide.
    ///
    /// - Parameters:
    ///   - routes: Le groupe de routes auquel ce contrôleur va ajouter ses routes.
    func boot(routes: any Vapor.RoutesBuilder) throws {
        // Groupe principal pour les routes des types d'activités physiques
        let typeActivities = routes.grouped("type_activities")
        
        typeActivities.get(use: self.getAll) // Récupération de tous les types d'activités
    }
    
    // MARK: - Fonction GETALL
    
    /// **Récupération de tous les types d'activités physiques.**
    /// Cette route renvoie une liste de tous les types d'activités physiques enregistrés dans la base de données.
    ///
    /// - Parameter req: La requête HTTP envoyée par le client.
    /// - Returns: Une liste d'objets `TypeActivity`.
    @Sendable
    func getAll(req: Request) async throws -> [TypeActivity] {
        let typeActivities = try await TypeActivity.query(on: req.db).all()
        req.logger.info("Retrieved typeActivities: \(typeActivities.count) typeActivities found.")
        return typeActivities
    }
}
