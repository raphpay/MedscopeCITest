import NIOSSL
import Fluent
import FluentMongoDriver
import Vapor
import SwiftOpenAPI

// configures your application
public func configure(_ app: Application) async throws {
    registerMiddlewares(app)
    app.routes.defaultMaxBodySize = "10000mb"

    try app.databases.use(DatabaseConfigurationFactory.mongo(
        connectionString: Environment.get("DATABASE_URL") ?? "mongodb://localhost:27017/vapor_database"
    ), as: .mongo)

    registerMigrations(app)
    try registerJobs(app)

    // register routes
    try routes(app)

    app.logger.info("Environment: \(app.environment.name)")
    app.logger.info("Log level: \(app.logger.logLevel)")

    let encoder = JSONEncoder()
    encoder.outputFormatting = .sortedKeys
    ContentConfiguration.global.use(encoder: encoder, for: .json)
}

func registerMiddlewares(_ app: Application) {
    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: .all, 
        allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
        allowedHeaders: [
            .accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent, .accessControlAllowOrigin,
            "api-key", "Access-Control-Allow-Origin", "fileName", "filePath", "Authorization", "Content-Type"
        ],
        exposedHeaders: ["Content-Disposition"]
    )
    let cors = CORSMiddleware(configuration: corsConfiguration)
    // cors middleware should come before default error middleware using `at: .beginning`
    app.middleware.use(cors, at: .beginning)

    app.middleware.use(
        FileMiddleware(
            publicDirectory: app.directory.publicDirectory,
            defaultFile: "index.html"
        )
    )

    // Custom middlewares
    app.middleware.use(PatientMiddleware(), at: .end)
}

func registerMigrations(_ app: Application) {
    app.migrations.add(CreateUser())
    app.migrations.add(CreateToken())
    app.migrations.add(CreatePatient())
    app.migrations.add(CreateDocument())
    app.migrations.add(CreateTreatment())
    app.migrations.add(CreateSurgeryPlan())
    app.migrations.add(CreateImplant())
    app.migrations.add(CreateMaterial())
    app.migrations.add(CreateAPIKey())
    app.migrations.add(CreateForm())
    app.migrations.add(CreateFileDownload())
    app.migrations.add(CreatePasswordResetToken())
    // Updates
    // 13/09/2024
    app.migrations.add(AddOptionalImplantsModelsToSurgeryPlan())
    app.migrations.add(UpdateUserAddOptionalAddress())
    // 19/09/2024
    app.migrations.add(AddResultsToSurgeryPlan())
    app.migrations.add(RemoveResultsFromSurgeryPlan())
    // 14/09/2024
    app.migrations.add(CreateVersionLog())
    app.migrations.add(CreateTreatmentFollowUp())
    // 29/11/2024
    app.migrations.add(AddConditionsFieldsToUsers())
    // 16/12/2024
    app.migrations.add(AddLoginFailedAttemptsToUsers())
    app.migrations.add(UpdateVersionLogParameters())
    // 06/03/2025
    app.migrations.add(RemoveSurgeryPlanParameters())
    app.migrations.add(AddIsTreatedParameterToSurgeryPlan())
    // 11/03/2025
    app.migrations.add(AddDepthParameterToImplant())
    // 14/03/2024
    app.migrations.add(RemoveDepthParameterFromImplant())
    app.migrations.add(AddDepthParameterToSurgeryPlan())
}

func registerJobs(_ app: Application) throws {
    app.queues.schedule(DeleteExpiredDownloadsJob())
        .daily()
        .at(.midnight)

    try app.queues.startScheduledJobs()
}
