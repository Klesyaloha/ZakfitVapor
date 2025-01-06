//
//  PhysicalActivityController.swift
//  ZakfitVapor
//
//  Created by Klesya on 04/01/2025.
//

import Vapor
import Fluent
import JWTKit

/// **Contrôleur pour gérer les activités physiques.**
/// Ce contrôleur fournit des routes pour créer, lire, mettre à jour et supprimer des activités physiques.
/// L'accès est restreint aux activités associées à l'utilisateur connecté.
struct PhysicalActivityController: RouteCollection {
    
    // MARK: - Routes
    
    /// Configure les routes associées au contrôleur.
    ///
    /// - Parameter routes: Le groupe de routes auquel ce contrôleur ajoute ses routes.
    func boot(routes: RoutesBuilder) throws {
        // Groupe principal pour les routes des activités physiques, protégé par un middleware d'authentification
        let activities = routes.grouped("physical_activities")
        // Routes protégées par JWT
        let tokenProtected = activities.grouped(JWTMiddleware())
        
        // Routes CRUD
        tokenProtected.post(use: self.create)          // Création d'une activité physique
        tokenProtected.get(use: self.getAllByUser)    // Récupération de toutes les activités de l'utilisateur
        tokenProtected.group(":activityID") { activity in
            activity.get(use: self.getById)       // Récupération d'une activité physique par ID
            activity.put(use: self.update)        // Mise à jour d'une activité physique
            activity.delete(use: self.delete)    // Suppression d'une activité physique
        }
    }
    
    // MARK: - Fonction POST
    /// **Création d'une nouvelle activité physique.**
    /// Cette route permet de créer une nouvelle activité physique associée à l'utilisateur connecté.
    ///
    /// - Parameter req: La requête HTTP contenant les données de l'activité physique à créer.
    /// - Returns: L'activité physique créée.
    @Sendable
    func create(req: Request) async throws -> PhysicalActivity {
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
        
        let input = try req.content.decode(PartialPhysicalActivity.self)
        
        let newActivity = PhysicalActivity(
            durationActivity: input.durationActivity,
            caloriesBurned: input.caloriesBurned,
            dateActivity: input.dateActivity,
            typeActivityID: input.typeActivityID,
            userID: user.id! // Force-unwrap car on sait que user existe et a un id non nil
        )
        
        try await newActivity.save(on: req.db)
        return newActivity
    }
    
    
    // MARK: - Fonction GETALL
    
    /// **Récupération de toutes les activités physiques de l'utilisateur connecté.**
    /// Cette route renvoie une liste d'activités physiques associées à l'utilisateur connecté.
    ///
    /// - Parameter req: La requête HTTP envoyée par le client.
    /// - Returns: Une liste d'objets `PhysicalActivity`.
    @Sendable
    func getAllByUser(req: Request) async throws -> [PhysicalActivity] {
        // Récupération de l'utilisateur connecté
        let user = try req.auth.require(User.self)
        
        // Récupération des activités physiques associées à cet utilisateur
        return try await PhysicalActivity.query(on: req.db)
            .filter(\.$user.$id == user.requireID())
            .all()
    }
    
    // MARK: - Fonction GET BY ID
    
    /// **Récupération d'une activité physique par son identifiant.**
    /// Cette route renvoie les détails d'une activité physique spécifique associée à l'utilisateur connecté.
    ///
    /// - Parameter req: La requête HTTP contenant l'ID de l'activité à récupérer.
    /// - Returns: L'objet `PhysicalActivity` correspondant à l'ID fourni.
    @Sendable
    func getById(req: Request) async throws -> PhysicalActivity {
        // Récupération de l'utilisateur connecté
        let user = try req.auth.require(User.self)
        
        // Extraction de l'ID de l'activité depuis les paramètres de la requête
        guard let activityID = req.parameters.get("activityID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "ID d'activité manquant ou invalide.")
        }
        
        // Recherche de l'activité physique associée à cet utilisateur
        guard let activity = try await PhysicalActivity.query(on: req.db)
            .filter(\.$id == activityID)
            .filter(\.$user.$id == user.requireID())
            .first() else {
            throw Abort(.notFound, reason: "Activité physique introuvable.")
        }
        
        // Retourne l'activité trouvée
        return activity
    }
    
    // MARK: - Fonction PUT
    
    /// **Mise à jour d'une activité physique.**
    /// Cette route met à jour les informations d'une activité physique associée à l'utilisateur connecté.
    ///
    /// - Parameter req: La requête HTTP contenant les données mises à jour de l'activité physique.
    /// - Returns: L'objet `PhysicalActivity` mis à jour.
    @Sendable
    func update(req: Request) async throws -> PhysicalActivity {
        // Récupération de l'utilisateur connecté
        let user = try req.auth.require(User.self)
        
        // Extraction de l'ID de l'activité depuis les paramètres de la requête
        guard let activityID = req.parameters.get("activityID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "ID d'activité manquant ou invalide.")
        }
        
        // Recherche de l'activité physique existante associée à cet utilisateur
        guard let existingActivity = try await PhysicalActivity.query(on: req.db)
            .filter(\.$id == activityID)
            .filter(\.$user.$id == user.requireID())
            .first() else {
            throw Abort(.notFound, reason: "Activité physique introuvable.")
        }
        
        // Décodage des données mises à jour
        let updatedData = try req.content.decode(PartialPhysicalActivity.self)
        
        // Mise à jour des propriétés
        existingActivity.durationActivity = updatedData.durationActivity
        existingActivity.caloriesBurned = updatedData.caloriesBurned
        existingActivity.dateActivity = updatedData.dateActivity
        existingActivity.$typeActivity.id = updatedData.typeActivityID
        
        // Sauvegarde des modifications dans la base de données
        try await existingActivity.save(on: req.db)
        
        // Retourne l'activité physique mise à jour
        return existingActivity
    }
    
    // MARK: - Fonction DELETE
    
    /// **Suppression d'une activité physique.**
    /// Cette route permet de supprimer une activité physique associée à l'utilisateur connecté.
    ///
    /// - Parameter req: La requête HTTP contenant l'ID de l'activité à supprimer.
    /// - Returns: Un statut HTTP indiquant si l'opération a réussi.
    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        // Récupération de l'utilisateur connecté
        let user = try req.auth.require(User.self)
        
        // Extraction de l'ID de l'activité depuis les paramètres de la requête
        guard let activityID = req.parameters.get("activityID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "ID d'activité manquant ou invalide.")
        }
        
        // Recherche de l'activité physique existante associée à cet utilisateur
        guard let activityToDelete = try await PhysicalActivity.query(on: req.db)
            .filter(\.$id == activityID)
            .filter(\.$user.$id == user.requireID())
            .first() else {
            throw Abort(.notFound, reason: "Activité physique introuvable.")
        }
        
        // Suppression de l'activité physique
        try await activityToDelete.delete(on: req.db)
        
        // Retourne un statut HTTP pour indiquer que l'opération a réussi
        return .noContent
    }
}

