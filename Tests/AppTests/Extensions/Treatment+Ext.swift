//
//  File.swift
//
//
//  Created by Raphaël Payet on 25/07/2024.
//

@testable import App
import XCTVapor
import Fluent

extension TreatmentControllerTests {
    /// Create a new treatment
    /// - Parameters:
    ///  - patientID: The ID of the patient
    /// - dicomID: The ID of the DICOM file
    /// - model3Ds: The IDs of the 3D models
    /// - save: Whether to save the treatment in the database
    /// - db: The database connection to use for the creation
    /// - Returns: The created treatment
    /// - Throws: An error if the treatment creation fails
    func createExpectedTreatment(with patientID: Patient.IDValue, and dicomID: Document.IDValue? = nil, model3Ds: [Document.IDValue]? = nil, save: Bool = true, on db: Database) async throws -> Treatment {
        var documentID: Document.IDValue = expectedDicomFileID
        if let dicomID = dicomID {
            documentID = dicomID
        }
        var model3DsIDs: [Document.IDValue] = [expectedDicomFileID]
        if let model3Ds = model3Ds {
            model3DsIDs = model3Ds
        }

        let treatment = Treatment(date: expectedDate, affectedBone: expectedAffectedBone, patientID: patientID, dicomID: documentID, model3Ds: model3DsIDs)
        if save == true {
            try await treatment.save(on: db)
        } else {
            treatment.id = UUID()
        }
        return treatment
    }

    /// Create a new treatment
    /// - Parameters:
    /// - patientID: The ID of the patient
    /// - dicomID: The ID of the DICOM file
    /// - model3Ds: The IDs of the 3D models
    /// - date: The date of the treatment
    /// - Returns: The created treatment
    /// - Throws: An error if the treatment creation fails
    func createExpectedTreatmentFormInput(with dicomID: Document.IDValue,
                                          model3Ds: [Document.IDValue],
                                          date: String? = nil
    ) -> Treatment.FormInput {
        var treatmentDate = date
        if date == nil {
            treatmentDate = expectedDate
        }

        return Treatment.FormInput(affectedBone: expectedAffectedBone,
                                   date: treatmentDate!,
                                   dicomID: dicomID,
                                   model3Ds: model3Ds
        )
    }
}

extension Treatment {
    /// Create a new treatment
    /// - Parameters:
    /// - date: The date of the treatment
    /// - affectedBone: The affected bone of the treatment
    /// - patientID: The ID of the patient
    /// - dicomID: The ID of the DICOM file
    /// - model3Ds: The IDs of the 3D models
    /// - db: The database connection to use for the creation
    /// - Returns: The created treatment
    /// - Throws: An error if the treatment creation fails
    static func create(date: String, affectedBone: Treatment.AffectedBone, patientID: Patient.IDValue, dicomID: Document.IDValue, model3Ds: [Document.IDValue], on db: Database) async throws -> Treatment {
        let treatment = Treatment(date: date, affectedBone: affectedBone, patientID: patientID, dicomID: dicomID, model3Ds: model3Ds)
        try await treatment.save(on: db)
        return treatment
    }
}
