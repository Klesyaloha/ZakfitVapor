import NIOSSL
import Fluent
import FluentMySQLDriver
import Vapor
import JWT

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin : .all,
        allowedMethods: [.GET, .POST, .PUT, .DELETE, .OPTIONS],
        allowedHeaders: [.accept, .authorization, .contentType, .origin],
        cacheExpiration: 1800
    )
    let corsMiddleware = CORSMiddleware(configuration: corsConfiguration)
    // Ajout du middleware CORS à l'application
    app.middleware.use(corsMiddleware)
    
    app.databases.use(DatabaseConfigurationFactory.mysql(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? MySQLConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "root",
        password: Environment.get("DATABASE_PASSWORD") ?? "",
        database: Environment.get("DATABASE_NAME") ?? "zakfit_db"
    ), as: .mysql)

//    app.migrations.add(CreateTodo())
    
    guard let secret = Environment.get("SECRET_KEY") else {
        fatalError("JWT secret is not set in environment variables")
    }
    
    // Création de la clé de signature avec l'algo HMAC
    let hmacKey = HMACKey(from: Data(secret.utf8))
    // Ajout de la clé de signature a la liste des clés JWT en précisant que l'on utilise l'algorithme SHA-256
    await app.jwt.keys.add(hmac: hmacKey, digestAlgorithm: .sha256)
    
    // En écoute sur toutes les interfaces réseau (0.0.0.0)
        app.http.server.configuration.hostname = "0.0.0.0"
        app.http.server.configuration.port = 8080
    
    // register routes
    try routes(app)
}
