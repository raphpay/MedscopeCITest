//
//  FormControllerTests+CREATE.swift
//
//
//  Created by Raphaël Payet on 18/07/2024.
//

@testable import App
import XCTVapor
import Fluent

// MARK: - CREATE
extension FormControllerTests {
    /// Tests the creation of a form
    /// Given: A valid user
    /// When: The form is created
    /// Then: The form is created successfully
    /// Note: The user should be an admin.
    func testCreateSucceed() async throws {
        let adminUser = try await UserControllerTests().createAdminUser(on: app.db)
        let adminUserID = try adminUser.requireID()
        let token = try await Token.create(with: adminUser, on: app.db)
        let expectedUser = UserControllerTests().createUserFormInput(id: nil, password: expectedPassword)

        let expectedPatientInput = PatientControllerTests().createExpectedPatientFormInput(with: adminUserID)

        let document = try await DocumentControllerTests().createExpectedDocument(on: app.db)
        let documentID = try document.requireID()

        let expectedTreatmentInput = TreatmentControllerTests().createExpectedTreatmentFormInput(with: documentID, model3Ds: [documentID])

        let _ = try await ImplantControllerTests().createExpectedImplant(with: documentID, on: app.db)

        let expectedSurgeryPlanInput = SurgeryPlanControllerTests().createExpectedSurgeryPlanFormInput(
            implantsModels: documentID, surgeryReport: [documentID],
            finalReport: documentID, surgeryGuide: documentID,
            resultsBoneStress: [documentID], resultsImplantStress: [documentID],
            resultsDensity: [documentID], otherResults: documentID
        )

        let input = Form.Input(user: expectedUser, patient: expectedPatientInput, treatment: expectedTreatmentInput, surgeryPlans: [expectedSurgeryPlanInput])

        try await app.test(.POST, baseURL) { req in
            try req.content.encode(input)
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
            do {
                let form = try res.content.decode(Form.self)
                XCTAssertEqual(form.user.name, expectedName)
                XCTAssertEqual(form.patient.firstName, expectedPatientInput.firstName.trimAndLowercase())
                // Test User
                let users = try await User.query(on: app.db).all()
                XCTAssertEqual(users.count, 2)
                XCTAssertEqual(users[1].name, expectedName)
                // Test Patient
                let patients = try await Patient.query(on: app.db).all()
                XCTAssertEqual(patients.count, 1)
                XCTAssertEqual(patients[0].name, expectedPatientName.trimAndLowercase())
                // Test Treatment
                let treatments = try await Treatment.query(on: app.db).all()
                XCTAssertEqual(treatments.count, 1)
                XCTAssertEqual(treatments[0].date, expectedTreatmentDate)
                // Test Surgery Plan
                let surgeryPlans = try await SurgeryPlan.query(on: app.db).all()
                XCTAssertEqual(surgeryPlans.count, 1)
            } catch { }
        }
    }

    /// Tests the creation of a form with an incorrect patient birthdate
    /// Given: A valid user
    /// When: The form is created
    /// Then: The form creation fails with a bad request error
    /// Note: The patient birthdate should be in the correct format and a valid date.
    func testCreateWithIncorrectPatientBirthdateFails() async throws {
        let adminUser = try await UserControllerTests().createAdminUser(on: app.db)
        let adminUserID = try adminUser.requireID()
        let token = try await Token.create(with: adminUser, on: app.db)
        let expectedUser = UserControllerTests().createUserFormInput(id: nil, password: expectedPassword)

        let expectedPatientInput = PatientControllerTests().createExpectedPatientFormInput(with: adminUserID, birthdate: incorrectPatientBirthdate)

        let document = try await DocumentControllerTests().createExpectedDocument(on: app.db)
        let documentID = try document.requireID()

        let expectedTreatmentInput = TreatmentControllerTests().createExpectedTreatmentFormInput(with: documentID, model3Ds: [documentID])

        let expectedSurgeryPlanInput = SurgeryPlanControllerTests().createExpectedSurgeryPlanFormInput()

        let input = Form.Input(user: expectedUser, patient: expectedPatientInput, treatment: expectedTreatmentInput, surgeryPlans: [expectedSurgeryPlanInput])

        try await app.test(.POST, baseURL) { req in
            try req.content.encode(input)
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.invalidPatientBirthdateFormat"))
        }
    }

    /// Tests the creation of a form with a wrong patient age
    /// Given: A valid user
    /// When: The form is created
    /// Then: The form creation fails with a bad request error
    func testCreateWithWrongPatientAgeFails() async throws {
        let adminUser = try await UserControllerTests().createAdminUser(on: app.db)
        let adminUserID = try adminUser.requireID()
        let token = try await Token.create(with: adminUser, on: app.db)
        let expectedUser = UserControllerTests().createUserFormInput(id: nil, password: expectedPassword)

        let expectedPatientInput = PatientControllerTests().createExpectedPatientFormInput(with: adminUserID, birthdate: wrongAgePatientBirthdate)

        let document = try await DocumentControllerTests().createExpectedDocument(on: app.db)
        let documentID = try document.requireID()

        let expectedTreatmentInput = TreatmentControllerTests().createExpectedTreatmentFormInput(with: documentID, model3Ds: [documentID])

        let expectedSurgeryPlanInput = SurgeryPlanControllerTests().createExpectedSurgeryPlanFormInput()

        let input = Form.Input(user: expectedUser, patient: expectedPatientInput, treatment: expectedTreatmentInput, surgeryPlans: [expectedSurgeryPlanInput])

        try await app.test(.POST, baseURL) { req in
            try req.content.encode(input)
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.invalidAge"))
        }
    }

    /// Tests the creation of a form with an incorrect treatment date
    /// Given: A valid user
    /// When: The form is created
    /// Then: The form creation fails with a bad request error
    /// Note: The treatment date should be in the correct format and a valid date.
    func testCreateWithInvalidTreatmentDateFails() async throws {
        let adminUser = try await UserControllerTests().createAdminUser(on: app.db)
        let token = try await Token.create(with: adminUser, on: app.db)
        let expectedUser = UserControllerTests().createUserFormInput(id: nil, password: expectedPassword)

        let expectedPatientInput = PatientControllerTests().createExpectedPatientFormInput()

        let document = try await DocumentControllerTests().createExpectedDocument(on: app.db)
        let documentID = try document.requireID()

        let expectedTreatmentInput = TreatmentControllerTests().createExpectedTreatmentFormInput(with: documentID, model3Ds: [documentID], date: incorrectTreatmentDate)

        let expectedSurgeryPlanInput = SurgeryPlanControllerTests().createExpectedSurgeryPlanFormInput()

        let input = Form.Input(user: expectedUser, patient: expectedPatientInput, treatment: expectedTreatmentInput, surgeryPlans: [expectedSurgeryPlanInput])

        try await app.test(.POST, baseURL) { req in
            try req.content.encode(input)
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.invaliTreatmentDateFormat"))
        }
    }

    /// Tests the creation of a form with an incorrect surgery plan date
    /// Given: A valid user
    /// When: The form is created
    /// Then: The form creation fails with a bad request error
    /// Note: The surgery plan date should be in the correct format and a valid date.
    func testCreateWithInexistantDicomFails() async throws {
        let adminUser = try await UserControllerTests().createAdminUser(on: app.db)
        let adminUserID = try adminUser.requireID()
        let token = try await Token.create(with: adminUser, on: app.db)
        let expectedUser = UserControllerTests().createUserFormInput(id: nil, password: expectedPassword)

        let expectedPatientInput = PatientControllerTests().createExpectedPatientFormInput(with: adminUserID)
        let document = try await DocumentControllerTests().createExpectedDocument(on: app.db)
        let documentID = try document.requireID()

        let expectedTreatmentInput = TreatmentControllerTests().createExpectedTreatmentFormInput(with: UUID(), model3Ds: [documentID])

        let expectedSurgeryPlanInput = SurgeryPlanControllerTests().createExpectedSurgeryPlanFormInput()

        let input = Form.Input(user: expectedUser, patient: expectedPatientInput, treatment: expectedTreatmentInput, surgeryPlans: [expectedSurgeryPlanInput])

        try await app.test(.POST, baseURL) { req in
            try req.content.encode(input)
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.inexistantDicomDocument"))
        }
    }

    /// Tests the creation of a form with an inexistant model 3D
    /// Given: A valid user
    /// When: The form is created
    /// Then: The form creation fails with a bad request error
    /// Note: The model 3D should be a valid UUID and the document should exist in the database.
    func testCreateWithInexistantModel3DFails() async throws {
        let adminUser = try await UserControllerTests().createAdminUser(on: app.db)
        let adminUserID = try adminUser.requireID()
        let token = try await Token.create(with: adminUser, on: app.db)
        let expectedUser = UserControllerTests().createUserFormInput(id: nil, password: expectedPassword)

        let expectedPatientInput = PatientControllerTests().createExpectedPatientFormInput(with: adminUserID)
        let document = try await DocumentControllerTests().createExpectedDocument(on: app.db)
        let documentID = try document.requireID()

        let expectedTreatmentInput = TreatmentControllerTests().createExpectedTreatmentFormInput(with: documentID, model3Ds: [UUID()])

        let expectedSurgeryPlanInput = SurgeryPlanControllerTests().createExpectedSurgeryPlanFormInput()

        let input = Form.Input(user: expectedUser, patient: expectedPatientInput, treatment: expectedTreatmentInput, surgeryPlans: [expectedSurgeryPlanInput])

        try await app.test(.POST, baseURL) { req in
            try req.content.encode(input)
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.inexistantModel3DDocument"))
        }
    }
}
