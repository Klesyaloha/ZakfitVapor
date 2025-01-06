//
//  GoalActivity.swift
//  ZakfitVapor
//
//  Created by Klesya on 04/01/2025.
//

import Fluent
import Vapor

final class GoalActivity: Model, Content, @unchecked Sendable {
    // MARK: - Nom de la table
    static let schema = "goal_activities" // Nom de la table dans la base de données

    // MARK: - Colonnes
    /// L'identifiant unique de l'objectif d'activité.
    @ID(custom: "id_goal_activity", generatedBy: .database)
    var id: UUID?

    /// La fréquence cible (nombre de répétitions par période, ex: "3 fois par semaine").
    @Field(key: "frequency")
    var frequency: Int?

    /// Le nombre de calories à atteindre dans cet objectif.
    @Field(key: "calories_goal_activity")
    var caloriesGoal: Double?

    /// La durée cible pour cet objectif (en minutes, par exemple).
    @Field(key: "duration_goal_activity")
    var durationGoal: Double?

    // MARK: - Relations
    /// L'utilisateur auquel cet objectif est associé.
    @Parent(key: "id_user")
    var user: User

    /// Le type d'activité auquel cet objectif est lié (ex: "Cardio", "Yoga").
    @Parent(key: "id_type_activity")
    var typeActivity: TypeActivity

    // MARK: - Constructeurs
    /// Constructeur par défaut requis par Fluent.
    init() { }

    /// Initialise un nouvel objectif d'activité avec les valeurs fournies.
    ///
    /// - Parameters:
    ///   - id: L'identifiant unique de l'objectif (facultatif).
    ///   - countFrequency: La fréquence cible (ex: "3").
    ///   - dayFrequency: La période de fréquence (ex: "par semaine").
    ///   - caloriesGoal: Le nombre de calories cible.
    ///   - durationGoal: La durée cible.
    ///   - userID: L'identifiant de l'utilisateur lié à cet objectif.
    ///   - typeActivityID: L'identifiant du type d'activité lié à cet objectif.
    init(id: UUID? = nil, frequency: Int?, caloriesGoal: Double?, durationGoal: Double?,  userID: UUID, typeActivityID: UUID) {
        self.id = id
        self.frequency = frequency
        self.caloriesGoal = caloriesGoal
        self.durationGoal = durationGoal
        self.$user.id = userID
        self.$typeActivity.id = typeActivityID
    }
}

struct PartialGoalActivity: Content {
    let frequency: Int?
    let caloriesGoal: Double?
    let durationGoal: Double?
    let typeActivityID: UUID
}
