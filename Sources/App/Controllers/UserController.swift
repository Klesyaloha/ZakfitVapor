//
//  UserController.swift
//  ZakfitVapor
//
//  Created by Klesya on 12/12/2024.
//

import Fluent
import Vapor

/**
    **Structure qui implémente l'interface RouteCollection.**
    Dans `Vapor`, une `RouteCollection` est un ensemble de routes qui sont regroupées
 sous un même contrôleur pour mieux organiser les endpoints de l'API ou de l'appication web.
 */
struct UserController : RouteCollection {
    
    /// Méthode requise par le protocole `RouteCollection`
    /// On y déclare touts les routes liées à ce contrôleur.
    func boot(routes: RoutesBuilder) throws {
        let users = routes.grouped("users")
        
        // Routes publiques
        users.post("register", use: self.create)
        
        // Authentification Basic
        let authGroup = users.grouped(User.authenticator(), User.guardMiddleware())
        authGroup.post("login", use: self.login)
        
        // Authentification par token
        let tokenProtected = users.grouped(TokenSession.authenticator(), TokenSession.guardMiddleware())
        tokenProtected.group(":userID") { user in
            user.get(use: self.getUserByID)
            user.put(use: self.update)
            user.delete(use: self.delete)
        }
    }
    
    /// **Fonction qui récupère la liste des users**
    /// - Parameters:
    ///   - req: Requête HTTP que le serveur a reçue. Contient toutes les infos de la requête :
    ///   (en-têtes HTTP, paramètre de l'URL, données POST)
    ///- Returns: Un tableau d'objets de type `User`.
    @Sendable
    func index(req: Request) async throws -> [User] {
        let users = try await User.query(on: req.db).all()
        req.logger.info("Retrieved users: \(users.count) users found.")
        return users
    }
    
    /// **Fonction qui crée un user.**
    /// Décode le corps de la requête pour extraire les informations de l'user
    /// Cryptage du mot de passe avec Brypt.
    /// - Parameters:
    ///   - req: Requête HTTP que le serveur a reçue. Contient toutes les infos de la requête :
    ///   (en-têtes HTTP, paramètre de l'URL, données POST).
    /// - Returns: Un objet de type `User`.
    @Sendable
    func create(req: Request) async throws -> User {
        let user = try req.content.decode(User.self)
        
        // Génération d'un UUID en Swift
        user.id = UUID()
        
        user.password = try Bcrypt.hash(user.password)
        try await user.save(on: req.db)
        return user
    }
    
    @Sendable
    func getUserByID(req: Request) async throws -> UserDTO {
        guard let user = try await User.find(req.parameters.get("userID"), on: req.db) else {
            throw Abort(.notFound, reason: "Utilisateur avec cet ID introuvable.")
        }
        return user.toDTO()
    }
    
    /// **Fonction qui supprime un user**
    /// Elle récupère un user par son ID puis le supprime de la BA.
    /// - Parameters:
    ///   - req: Requête HTTP que le serveur a reçue. Contient toutes les infos de la requête :
    ///   (en-têtes HTTP, paramètre de l'URL, données POST).
    /// - Returns: Un status HTTP indiquant le si l'opération à réussie..
    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let utilisateur = try await
            User.find(req.parameters.get("userID"), on: req.db) else {
            throw Abort (.notFound)
        }
        
        try await utilisateur.delete(on: req.db)
        return .noContent
    }
    
    /// **Fonction qui modifie un user.**
    /// Convertie le userIDString récupéré en UUID puis modifie l'user associé si l'id existe et qu'il est valide.
    /// Décode le corps de la requête HTTP en un objet `User`, les nouvelles données de l'user sont ainsi extraites du JSON fourni par le client et appliquées à l'user existant.
    /// - Parameters:
    ///   - req: Requête HTTP que le serveur a reçue. Contient toutes les infos de la requête :
    ///   (en-têtes HTTP, paramètre de l'URL, données POST).
    /// - Returns: Un objet de type `User`.
    @Sendable
    func update(req: Request) async throws -> User {
        guard let userIDString = req.parameters.get("userID"),
              let userID = UUID(uuidString: userIDString) else {
            throw Abort(.badRequest, reason: "ID d'utilisateur invalide.")
        }
        let updatedFields = try req.content.decode(PartialUserUpdate.self)
        
        guard let user = try await User.find(userID, on: req.db) else {
            throw Abort(.notFound, reason: "Utilisateur non trouvé.")
        }
        
        // Mettre à jour les propriétés si elles sont fournies
        if let nameUser = updatedFields.nameUser {
            user.nameUser = nameUser
        }
        if let surname = updatedFields.surname {
            user.surname = surname
        }
        if let email = updatedFields.email {
            user.email = email
        }
        if let password = updatedFields.password {
            user.password = try Bcrypt.hash(password) // Hash le mot de passe si mis à jour
        }
        if let size = updatedFields.sizeUser {
            user.sizeUser = size
        }
        if let weight = updatedFields.weight {
            user.weight = weight
        }
        if let healthChoice = updatedFields.healthChoice {
            user.healthChoice = healthChoice
        }
        if let eatChoice = updatedFields.eatChoice {
            user.eatChoice = eatChoice
        }
        
        try await user.save(on: req.db)
        return user
    }
    
    @Sendable
    func login(req: Request) async throws -> LoginResponse {
        // Récupération des logins/mdp
        let user = try req.auth.require(User.self)
        
        // Création du payload en fonction des informations du user
        let payload = try TokenSession(with: user)
        
        // Création d'un token signé à partir du payload
        let token = try await req.jwt.sign(payload)
        
        // Retourne une instance de LoginResponse
        return LoginResponse(token: token, user: user)
    }
}
