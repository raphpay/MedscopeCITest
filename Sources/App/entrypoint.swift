import Vapor
import Logging
import NIOCore
import NIOPosix

@main
enum Entrypoint {
    static func main() async throws {
        var env = try Environment.detect()
        try LoggingSystem.bootstrap(from: &env)

        let app = try await Application.make(env)

        // This attempts to install NIO as the Swift Concurrency global executor.
        // You should not call any async functions before this point.
        let executorTakeoverSuccess = NIOSingletons
			.unsafeTryInstallSingletonPosixEventLoopGroupAsConcurrencyGlobalExecutor()
		let run = "\(executorTakeoverSuccess ? "SwiftNIO" : "standard")"
		let log = Logger.Message(stringLiteral: "Running with \(run) Swift Concurrency default executor")
        app.logger
			.debug(log)

        do {
            try await configure(app)
        } catch {
            app.logger.report(error: error)
            try? await app.asyncShutdown()
            throw error
        }
        try await app.execute()
        try await app.asyncShutdown()
    }
}
