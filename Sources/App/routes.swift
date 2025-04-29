import Fluent
import Vapor
import VaporToOpenAPI

func routes(_ app: Application) throws {
    app.get { _ async in
        "The Medscope API works!"
    }

    app.get("hello") { _ async -> String in
        "Hello, world!"
    }

    app.get("version") { _ async -> String in
        "2024.09.27-1"
    }

    // Controllers
    try app.register(collection: UserController())
    try app.register(collection: PatientController())
    try app.register(collection: DocumentController())
    try app.register(collection: TreatmentController())
    try app.register(collection: SurgeryPlanController())
    try app.register(collection: ImplantController())
    try app.register(collection: MaterialController())
    try app.register(collection: OpenAPIController())
    try app.register(collection: APIKeyController())
    try app.register(collection: FormController())
    try app.register(collection: TokenController())
    try app.register(collection: EmailController())
    try app.register(collection: FileDownloadController())
    try app.register(collection: VersionLogController())
    try app.register(collection: TreatmentFollowUpController())
    try app.register(collection: PasswordResetTokenController())
}
