//
//  GoalActivityController.swift
//  ZakfitVapor
//
//  Created by Klesya on 04/01/2025.
//

import Fluent
import Vapor

/**
    **Contrôleur qui gère les opérations sur les objectifs d'activités physiques.**
    Ce contrôleur permet de créer, récupérer, mettre à jour et supprimer des objectifs d'activités physiques associés à un utilisateur.
    Il est protégé par un système d'authentification via token.
 */
struct GoalActivityController : RouteCollection {
    // MARK: - Routes
    /// **Fonction qui configure les routes du contrôleur.**
    /// Elle groupe les routes sous `/goal_activities` et s'assure que l'accès est protégé par un token valide.
    ///
    /// - Parameters:
    ///   - routes: Le groupe de routes auquel ce contrôleur va ajouter ses routes.
    func boot(routes: any Vapor.RoutesBuilder) throws {
        // Groupe protégé par Token
        let protectedRoutes = routes.grouped(JWTMiddleware())
        
        // Groupe des routes pour les objectifs d'activités
        let goalActivities = protectedRoutes.grouped("goal_activities")
        
        goalActivities.post(use: self.create) // Création d'un objectif d'activité
        goalActivities.get(use: self.getAll) // Récupération de tous les objectifs d'activité de l'utilisateur
        
        goalActivities.group(":goalActivityID") { goalActivity in
            goalActivity.put(use: self.update) // Mise à jour d'un objectif d'activité
            goalActivity.delete(use: self.delete) // Suppression d'un objectif d'activité
        }
    }
    
    // MARK: - Fonction POST
    /// **Fonction qui crée un objectif d'activité physique.**
    /// Cette fonction permet de créer un nouvel objectif d'activité physique pour un utilisateur donné, en prenant en compte les informations transmises dans la requête.
    ///
    /// - Parameters:
    ///   - req: La requête HTTP envoyée par le client. Elle contient toutes les infos nécessaires pour créer un objectif d'activité.
    /// - Returns: Un objet `GoalActivity` représentant l'objectif d'activité créé.
    @Sendable
    func create(req: Request) async throws -> GoalActivity {
        // Afficher le token reçu dans l'en-tête
        if let token = req.headers[.authorization].first {
            print("Token reçu : \(token)")
        } else {
            print("Aucun token trouvé dans les en-têtes.")
        }
        
        // Vérifier que l'utilisateur est authentifié
        let user: User // Déclaration de la variable user en dehors du do-catch
        do {
            user = try req.auth.require(User.self)
            print("Utilisateur authentifié avec ID : \(String(describing: user.id))")
        } catch {
            print("Erreur d'authentification : \(error)")
            throw Abort(.unauthorized, reason: "Token invalide ou utilisateur non trouvé.")
        }
        
        // Décodage du body de la requête
        let input = try req.content.decode(PartialGoalActivity.self)
        
        // Création de l'activité
        let newGoalActivity = GoalActivity(id: UUID(), frequency: input.frequency, caloriesGoal: input.caloriesGoal, durationGoal: input.durationGoal, userID: user.id!, typeActivityID: input.typeActivityID)
        
        try await newGoalActivity.save(on: req.db)
        
        return newGoalActivity
    }
    
    // MARK: - Fonction GETALL
    /// **Fonction qui récupère la liste des objectifs d'activités pour un utilisateur donné.**
    /// Cette fonction permet de récupérer tous les objectifs d'activités physiques associés à un utilisateur, identifiés par leur `userID`.
    ///
    /// - Parameters:
    ///   - req: La requête HTTP envoyée par le client. Elle contient l'identifiant de l'utilisateur dans l'URL.
    /// - Returns: Un tableau d'objets `GoalActivity` représentant les objectifs d'activités de l'utilisateur.
    @Sendable
    func getAll(req: Request) async throws -> [GoalActivity] {
        // Récupération de l'utilisateur connecté
        let user = try req.auth.require(User.self)
        
        // Recherche des GoalActivity associées à cet userID dans la base de données
        let activities = try await GoalActivity.query(on: req.db)
            .filter(\.$user.$id == user.requireID()) // Filtrer par userID
            .all()
        
        // Retourner les activités trouvées
        return activities
    }
    
    // MARK: - Fonction PUT
    /// **Fonction qui met à jour un objectif d'activité physique.**
    /// Cette fonction permet de modifier un objectif existant en utilisant son `goalID` et les nouvelles informations envoyées par le client.
    ///
    /// - Parameters:
    ///   - req: La requête HTTP contenant les informations nécessaires pour mettre à jour l'objectif.
    /// - Returns: L'objet `GoalActivity` mis à jour.
    @Sendable
    func update(req: Request) async throws -> GoalActivity {
        // Récupération de l'utilisateur connecté
        let user = try req.auth.require(User.self)
        
        // Récupérer l'ID de l'objectif depuis les paramètres de la requête
        guard let goalID = req.parameters.get("goalActivityID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "ID d'objectif invalide.")
        }
        
        // Décoder les données envoyées par le client dans la requête
        let updatedGoal = try req.content.decode(PartialGoalActivity.self)
        
        // Recherche de l'objectif d'activité avec cet ID dans la base
        guard let existingGoal = try await GoalActivity.query(on: req.db)
            .filter(\.$id == goalID)
            .filter(\.$user.$id == user.requireID())
            .first() else {
            throw Abort(.notFound, reason: "Objectif non trouvé.")
        }
        
        // Mettre à jour les propriétés de l'objectif existant avec les nouvelles données
        existingGoal.frequency = updatedGoal.frequency
        existingGoal.caloriesGoal = updatedGoal.caloriesGoal
        existingGoal.durationGoal = updatedGoal.durationGoal
        existingGoal.$typeActivity.id = updatedGoal.typeActivityID
        
        // Sauvegarder l'objectif mis à jour dans la base de données
        try await existingGoal.save(on: req.db)
        
        // Retourner l'objectif mis à jour
        return existingGoal
    }
    
    // MARK: - Fonction DELETE
    /// **Fonction qui supprime un objectif d'activité physique.**
    /// Cette fonction permet de supprimer un objectif d'activité physique en utilisant son `goalID`.
    ///
    /// - Parameters:
    ///   - req: La requête HTTP contenant l'ID de l'objectif à supprimer.
    /// - Returns: Un statut HTTP indiquant si l'opération a réussie.
    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        // Récupération de l'utilisateur connecté
        let user = try req.auth.require(User.self)
        
        guard let goalID = req.parameters.get("goalActivityID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "ID d'objectif invalide.")
        }
        
        // Recherche de l'objectif d'activité existante associée à cet utilisateur
        guard let goalToDelete = try await GoalActivity.query(on: req.db)
            .filter(\.$id == goalID)
            .filter(\.$user.$id == user.requireID())
            .first() else {
            throw Abort(.notFound, reason: "Objectif non trouvé.")
        }
        
        // Supprimer l'objectif de la base de données
        try await goalToDelete.delete(on: req.db)
        
        // Retourner un statut HTTP No Content pour indiquer que la suppression a été effectuée
        return .noContent
    }
}
