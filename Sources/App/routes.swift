import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }

    try app.register(collection: UserController())
    try app.register(collection: PhysicalActivityController())
    try app.register(collection: TypeActivityController())
    try app.register(collection: GoalActivityController())
    try app.register(collection: FoodController())
    try app.register(collection: MealController())
    try app.register(collection: CompositionController())
}
