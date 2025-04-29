//
//  UserControllerTests+READ.swift
//
//
//  Created by Raphaël Payet on 14/07/2024.
//

@testable import App
import XCTVapor
import Fluent

// MARK: - Get All
extension UserControllerTests {
    func testGetAllUserWithUsersSucceed() async throws {
        let _ = try await UserControllerTests().createExpectedUser(on: app.db)
        
        try await app.test(.GET, "api/users") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
            do {
                let users = try res.content.decode([User].self)
                XCTAssertEqual(users.count, 1)
                XCTAssertEqual(users[0].name, expectedName)
                XCTAssertEqual(users[0].firstName, expectedFirstName)
                XCTAssertEqual(users[0].address, expectedAddress)
            } catch { }
        }
    }
    
    func testGetAllUserWithNoUserSucceed() async throws {
        try await app.test(.GET, "api/users") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
            do {
                let users = try res.content.decode([User].self)
                XCTAssertEqual(users.count, 0)
            } catch { }
        }
    }
}

// MARK: - Get User
extension UserControllerTests {
    func testGetUserSucceed() async throws {
        let user = try await UserControllerTests().createExpectedUser(on: app.db)
        let userID = try user.requireID()
        
        try await app.test(.GET, "api/users/\(userID)") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
            do {
                let user = try res.content.decode(User.self)
                XCTAssertEqual(user.name, expectedName)
                XCTAssertEqual(user.firstName, expectedFirstName)
                XCTAssertEqual(user.address, expectedAddress)
            } catch { }
        }
    }
    
    func testGetUserWithWrongUserIDFails() async throws {
        try await app.test(.GET, "api/users/userID") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.missingUserID"))
        }
    }
    
    func testGetUserWithInexistantUserFails() async throws {
        let falseUserID = UUID()
        try await app.test(.GET, "api/users/\(falseUserID)") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.user"))
        }
    }
}

// MARK: - Get Patients
extension UserControllerTests {
    // TODO: To be finished when the problem with the migration is corrected
    func testGetPatientsWithPatientsSucceed() async throws {
        let user = try await UserControllerTests().createExpectedUser(on: app.db)
        let userID = try user.requireID()
        let _ = try await Patient.create(
            name: expectedPatientName, firstName: expectedPatientFirstName,
            birthdate: expectedBirthdate, gender: expectedGender,
            userID: userID, medscopeID: expectedPatientMedscopeID,
            laGalaxyID: expectedPatientLaGalaxyID,
            on: app.db
        )
        
        try await app.test(.GET, "\(baseURL)/patients/\(userID)") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
            do {
                let patients = try res.content.decode([Patient].self)
                XCTAssertEqual(patients.count, 1)
                XCTAssertEqual(patients[0].name, expectedPatientName.trimAndLowercase())
                XCTAssertEqual(patients[0].firstName, expectedPatientFirstName.trimAndLowercase())
                XCTAssertEqual(patients[0].birthdate, expectedBirthdate)
                XCTAssertEqual(patients[0].gender, expectedGender)
                XCTAssertEqual(patients[0].$user.id, userID)
                XCTAssertEqual(patients[0].laGalaxyID, expectedPatientLaGalaxyID)
            } catch { }
        }
    }
    
    func testGetPatientsWithNoPatientSucceed() async throws {
        let user = try await UserControllerTests().createExpectedUser(on: app.db)
        let userID = try user.requireID()
        
        try await app.test(.GET, "\(baseURL)/patients/\(userID)") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
            
        }
    }
    
    func testGetPatientWithIncorrectUserIDFails() async throws {
        try await app.test(.GET, "\(baseURL)/patients/userID") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.missingUserID"))
        }
    }
    
    func testGetPatientWithInexistantUserFails() async throws {
        let falseUserID = UUID()
        
        try await app.test(.GET, "\(baseURL)/patients/\(falseUserID)") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.user"))
        }
    }
}

// MARK: - Get User's Patient
extension UserControllerTests {
    func testGetUsersPatientSucceed() async throws {
        let user = try await UserControllerTests().createExpectedUser(on: app.db)
        let userID = try user.requireID()
        
        let patient = try await PatientControllerTests().createExpectedPatient(with: userID, save: true, on: app.db)
        let patientID = try patient.requireID()
        
        try await app.test(.GET, "\(baseURL)/\(userID)/patient/\(patientID)") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
            do {
                let patient = try res.content.decode(Patient.self)
                XCTAssertEqual(patient.$user.id, userID)
                XCTAssertEqual(patient.id, patientID)
            } catch { }
        }
    }
    
    func testGetUsersPatientWithIncorrectUserIDFails() async throws {
        let wrongUserID = UUID()
        
        let patient = try await PatientControllerTests().createExpectedPatient(with: wrongUserID, save: true, on: app.db)
        let patientID = try patient.requireID()
        
        try await app.test(.GET, "\(baseURL)/\(wrongUserID)/patient/\(patientID)") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.user"))
        }
    }
    
    func testGetUsersPatientWithIncorrectPatientIDFails() async throws {
        let user = try await UserControllerTests().createExpectedUser(on: app.db)
        let userID = try user.requireID()
        
        let wrongPatientID = UUID()
        
        try await app.test(.GET, "\(baseURL)/\(userID)/patient/\(wrongPatientID)") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.patient"))
        }
    }
    
    func testGetUsersPatientWithNoAccessFails() async throws {
        let user = try await UserControllerTests().createExpectedUser(on: app.db)
        let userID = try user.requireID()
        
        let patient = try await PatientControllerTests().createExpectedPatient(with: UUID(), save: true, on: app.db)
        let patientID = try patient.requireID()
        
        try await app.test(.GET, "\(baseURL)/\(userID)/patient/\(patientID)") { req in
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .expectationFailed)
            XCTAssertTrue(res.body.string.contains("expectationFailed.userNotLinkedToPatient"))
        }
    }
}
