//
//  SurgeryPlanControllerTests.swift
//
//
//  Created by Raphaël Payet on 15/07/2024.
//

@testable import App
import XCTVapor
import Fluent

final class SurgeryPlanControllerTests: XCTestCase {
    var app: Application!
    var apiKey: APIKey!
    var token: Token!
    let baseURL = "api/surgeryPlans"
    
    override func setUp() async throws {
        self.app = try await Application.make(.testing)
        try await configure(app)
        try await app.autoMigrate()
        token = try await Token.saveToken(on: app.db)
        apiKey = try await APIKey.saveAPIKey(on: app.db)
    }
    
    override func tearDown() async throws {
        // Clean db
        try await apiKey?.delete(force: true, on: app.db)
        try await token.delete(force: true, on: app.db)
        try await User.query(on: app.db).all().delete(force: true, on: app.db)
        try await Token.query(on: app.db).all().delete(force: true, on: app.db)
        try await SurgeryPlan.query(on: app.db).all().delete(force: true, on: app.db)
        try await Document.query(on: app.db).all().delete(force: true, on: app.db)
        try await Implant.query(on: app.db).all().delete(force: true, on: app.db)
        try await Treatment.query(on: app.db).all().delete(force: true, on: app.db)
        try await Patient.query(on: app.db).all().delete(force: true, on: app.db)
        try await app.autoRevert()
        try await self.app.asyncShutdown()
        self.app = nil
    }
    
    // Expected Properties
    let expectedMedscopeID = "PLAN00000001"
    let expectedNaturalTeeth = [1, 2, 3]
    let expectedArtificialTeeth = [1, 2, 3]
    let expectedPosition = [1, 2, 3]
    
    let expectedCenter = [[Float(15.02), Float(201), Float(3)]]
    let expectedApex = [[Float(15.02), Float(201), Float(3)]]
    let expectedUpIndex = [[Float(15.02), Float(201), Float(3)]]
    
    let expectedImplantsReference = ["K43608"]
    
    let expectedLoadingProtocol = "expectedLoadingProtocol"
    
    let expectedDensityScale = [Float(15.02), Float(201), Float(3), Float(76.09), Float(8.98)]
    let expectedBoneStressScale = [Float(15.02), Float(201), Float(3)]
    let expectedImplantStressScale = [Float(15.02), Float(201), Float(3)]
    
    let expectedMessageBoneStress = ["expectedMessage", "BoneStress"]
    let expectedMessageImplantStress = ["expectedMessage", "ImplantStress"]
    let expectedMessagesDensity = ["expectedMessage", "messagesDensity"]
    
    let expectedScoresBoneStress = [1, 2, 3]
    let expectedScoresImplantStress = [1, 2, 3]
    let expectedScoresDensity = [1, 2, 3]
    
    let expectedImagesBoneStress = [UUID(), UUID()]
    let expectedImagesImplantStress = [UUID(), UUID()]
    let expectedImagesDensity = [UUID(), UUID()]
    let expectedImagesBoneQualityPercentage = [UUID(), UUID()]
    let expectedImagesEstimatedBoneType = [UUID(), UUID()]
    let expectedImagesRadio = [UUID(), UUID()]
    let expectedImagesDrillingProfile = [UUID(), UUID()]
    
    let expectedEstimatedCorticalThickness = Float(152.08)
    let expectedEstimatedTrabecularDensity = Float(152.08)
    let expectedEstimatedCrestalThickness = Float(152.08)
    
    let expectedIsTreated = true
    let expectedDepth = [Float(15.02), Float(201), Float(3)]
    
    let wrongNaturalTeeth = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33]
    let wrongDensityScale = [Float(15.02), Float(201), Float(3)]
    let wrongBoneStressScale = [Float(15.02), Float(201), Float(3), Float(15.02), Float(201), Float(3), Float(15.02), Float(201), Float(3), Float(15.02), Float(201), Float(3)]
    
    // Mandible File
    let expectedMandibleFileName = "expectedMandibleFileName"
    let expectedMandibleFilePath = "expectedMandible/FilePath"
    
    // Maxillary File
    let expectedMaxillaryFileName = "expectedMaxillaryFileName"
    let expectedMaxillaryFilePath = "expectedMaxillary/FilePath"
    
    // Implant
    let implantExpectedReference = "implantExpectedReference"
    let expectedInternalDiam = Float(514)
    let expectedAbutmentContactHeight = Float(513)
    let expectedDiameter = Float(512)
    let expectedHneck = Float(511)
    let expectedLength = Float(510)
    let expectedMatName = "expectedMatName"
    let expectedUpCenter = [Float(16), Float(76)]
    let expectedCenterZ = [Float(1), Float(7)]
    let expectedUpIndexImplant = [Float(160), Float(760)]
    
    // Updated properties
    let expectedUpdatedNaturalTeeth = [3,4,5]
    let expectedUpdatedArtificialTeeth = [3,4,5]
    let expectedUpdatedPosition = [3,4,5]
    let expectedUpdatedCenter = [[Float(3), Float(44), Float(5)], [Float(3), Float(44), Float(5)]]
    let expectedUpdatedApex = [[Float(3), Float(44), Float(5)], [Float(3), Float(44), Float(5)]]
    let expectedUpdatedUpIndex = [[Float(3), Float(44), Float(5)], [Float(3), Float(44), Float(5)]]
    let expectedUpdatedMessagesImplantStress = ["expected", "Updated", "ImplantStress"]
    let expectedUpdatedEstimatedCrestalThickness = Float(209.87)
    let expectedUpdatedLoadingProtocol = "Expected Loading Protocol"
    let expectedUpdatedDensityScale: [Float] = [1.0, 2.0, 3.0]
    let expectedUpdatedBoneStressScale: [Float] = [1.0, 2.0, 3.0]
    let expectedUpdatedImplantStressScale: [Float] = [1.0, 2.0, 3.0]
    let expectedUpdatedMessagesBoneStress: [String] = ["expected", "Bone", "Stress"]
    let expectedUpdatedMessagesDensity: [String] = ["expected", "Density", "Messages"]
    let expectedUpdatedScoresBoneStress: [Int] = [5, 10, 15]
    let expectedUpdatedScoresImplantStress: [Int] = [5, 10, 15]
    let expectedUpdatedScoresDensity: [Int] = [5, 10, 15]
    let expectedUpdatedEstimatedCorticalThickness: Float = 120.55
    let expectedUpdatedEstimatedTrabecularDensity: Float = 75.34

    // Incorrect Values
    let incorrectUpdatedSurgeryReport: [Document.IDValue] = Array(repeating: UUID(), count: 35)
    let incorrectUpdatedMessagesBoneStress: [String] = Array(repeating: "Incorrect", count: 35)
    let incorrectUpdatedImagesBoneStress: [Document.IDValue] = Array(repeating: UUID(), count: 35)
    let incorrectUpdatedResultsBoneStress: [Document.IDValue] = Array(repeating: UUID(), count: 35)
    // Incorrect properties
    let incorrectMessagesImplantStress = [
        "1", "2", "3", "4", "5", "6", "7", "8", "9", "10",
        "11", "12", "13", "14", "15", "16", "17", "18", "19", "20",
        "21", "22", "23", "24", "25", "26", "27", "28", "29", "30",
        "31", "32", "33", "34", "35"
    ]
    let incorrectImplantReferences = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10",
                                      "11", "12", "13", "14", "15", "16", "17", "18", "19", "20",
                                      "21", "22", "23", "24", "25", "26", "27", "28", "29", "30",
                                      "31", "32", "33", "34", "35"]

}
