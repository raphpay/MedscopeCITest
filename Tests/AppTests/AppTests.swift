@testable import App
import XCTVapor
import Fluent


final class AppTests: XCTestCase {
    var app: Application!
    
    override func setUp() async throws {
        self.app = try await Application.make(.testing)
        try await configure(app)
        try await app.autoMigrate()
    }
    
    override func tearDown() async throws { 
        try await app.autoRevert()
        try await self.app.asyncShutdown()
        self.app = nil
    }
    
    func testHelloWorld() async throws {
        try await self.app.test(.GET, "hello", afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.body.string, "Hello, world!")
        })
    }
}

//extension TodoDTO: Equatable {
//    public static func == (lhs: Self, rhs: Self) -> Bool {
//        lhs.id == rhs.id && lhs.title == rhs.title
//    }
//}

