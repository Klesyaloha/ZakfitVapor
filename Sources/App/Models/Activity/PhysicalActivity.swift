//
//  PhysicalActivities.swift
//  ZakfitVapor
//
//  Created by Klesya on 04/01/2025.
//

import Vapor
import Fluent


/**
    **Documentation de la classe PhysicalActivity.**
    Représente une activité physique spécifique associée à un type d'activité (`TypeActivity`).
 */
final class PhysicalActivity: Model, Content, @unchecked Sendable {
    // MARK: - Nom de la table
    static let schema = "physical_activities" // Nom de la table dans la base de données
    
    // MARK: - Colonnes
    /// L'identifiant unique de l'activité physique.
    @ID(custom: "id_physical_activity", generatedBy: .database)
    var id: UUID?
    
    /// La durée de l'activité (en minutes, par exemple).
    @Field(key: "duration_activity")
    var durationActivity: Double
    
    /// Le nombre de calories brûlées pendant l'activité (facultatif).
    @Field(key: "calories_burned")
    var caloriesBurned: Double?
    
    /// La date et l'heure de l'activité.
    @Field(key: "date_activity")
    var dateActivity: Date
    
    /// L'user à qui cette activité physique est associée.
    @Parent(key: "id_user")
    var user: User
    
    /// Le type d'activité auquel cette activité physique est associée.
    @Parent(key: "id_type_activity")
    var typeActivity: TypeActivity
    
    // MARK: - Constructeurs
    /// Constructeur par défaut requis par Fluent.
    init() { }
    
    /// Initialise une nouvelle activité physique avec les valeurs fournies.
    ///
    /// - Parameters:
    ///   - id: L'identifiant unique de l'activité (facultatif).
    ///   - duration: La durée de l'activité.
    ///   - caloriesBurned: Les calories brûlées pendant l'activité (facultatif).
    ///   - date: La date et l'heure de l'activité.
    ///   - typeActivityID: L'identifiant du type d'activité associé.
    init(id: UUID? = nil, durationActivity: Double, caloriesBurned: Double? = nil, dateActivity: Date, typeActivityID: UUID, userID: UUID) {
        self.id = UUID()
        self.durationActivity = durationActivity
        self.caloriesBurned = caloriesBurned
        self.dateActivity = dateActivity
        self.$typeActivity.id = typeActivityID
        self.$user.id = userID
    }
}

struct PartialPhysicalActivity: Content {
    let durationActivity: Double
    let caloriesBurned: Double?
    let dateActivity: Date
    let typeActivityID: UUID
}
