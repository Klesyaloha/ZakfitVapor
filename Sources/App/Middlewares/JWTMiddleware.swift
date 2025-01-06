//
//  JWTMiddleware.swift
//  ZakfitVapor
//
//  Created by Klesya on 05/01/2025.
//

import Vapor
import JWTKit

struct JWTMiddleware: AsyncMiddleware {
    
    func respond(to request: Vapor.Request, chainingTo next: any Vapor.AsyncResponder) async throws -> Vapor.Response {
        // Vérifier si l'en-tête "Authorization" est présent
        guard let authorizationHeader = request.headers[.authorization].first else {
            throw Abort(.unauthorized, reason: "En-tête Authorization manquant.")
        }

        // Extraire le token Bearer
        let tokenString = authorizationHeader.replacingOccurrences(of: "Bearer ", with: "")

        do {
            // Décoder et vérifier le token JWT
            let payload = try await request.jwt.verify(tokenString, as: TokenSession.self)
            
            // Extraire l'UUID de l'utilisateur depuis le payload
            let userId = payload.userId
            
            // Charger l'utilisateur à partir de la base de données en fonction de l'UUID
            guard let user = try await User.find(userId, on: request.db) else {
                throw Abort(.unauthorized, reason: "Utilisateur non trouvé.")
            }
            
            // Connecter l'utilisateur
            request.auth.login(user)
            
            // Passer au middleware suivant
            return try await next.respond(to: request)
        } catch let jwtError as JWTError { // Capture les erreurs JWT spécifiques
            print("Erreur JWT : \(jwtError)")
            throw Abort(.unauthorized, reason: "Token JWT invalide : \(jwtError)")
        } catch let abortError as AbortError { // Capture les erreurs Abort
            print("Erreur Abort : \(abortError.reason)")
            throw abortError
        } catch { // Capture les autres erreurs (moins spécifiques, mais utile pour le débogage)
            print("Autre erreur : \(error)")
            throw Abort(.internalServerError, reason: "Erreur interne du serveur.") // Changer le statut pour plus de précision
        }
    }
}
