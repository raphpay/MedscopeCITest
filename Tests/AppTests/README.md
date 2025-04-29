# Local Testing Instructions

To run the tests locally for the Medscope API project, follow these steps:

## Requirements

Before you begin, ensure you have followed the installation process from the main README.md file.

# How to write tests

## Understanding BDD (Behavior Driven Development)

Behavior Driven Development (BDD) is a testing approach that emphasizes writing tests in a way that reflects the expected behavior of a system from the perspective of its users or stakeholders. It uses structured scenarios to describe the context, action, and expected outcome of a feature or function.

### Key Principles

- **Given (Preconditions):** Describes the initial state or context. This includes setup like data creation, configuration, or system state required for the test.
- **When (Action):** Specifies the action or event that triggers the behavior. This is what the test is evaluating.
- **Then (Expected Result):** Outlines the expected outcome or change in system state after the action is performed.

### Example in Swift

```swift
/// Test the update of a surgery plan
/// - Given: A surgery plan with a treatment
/// - When: A PUT request is sent to the update endpoint
/// - Then: The surgery plan is updated with the new values
func testUpdateSucceed() async throws {
    // Given
    let user = try await UserControllerTests().createExpectedUser(on: app.db)
    let userID = try user.requireID()

    let updatedUser = User.UpdateInput(name: updatedName, firstName: updatedFirstName,
                                      address: updatedAddress, mailAddress: nil,
                                      conditionsAccepted: nil, conditionsAcceptedTimestamp: nil,
                                      role: updatedRole)
    // When
    try await app.test(.PUT, "\(baseURL)/\(userID)") { req in
      try req.content.encode(updatedUser)
      req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
    } afterResponse: { res async in
      // Then
      XCTAssertEqual(res.status, .ok)
        do {
          let user = try res.content.decode(User.self)
          XCTAssertEqual(user.name, updatedName)
          XCTAssertEqual(user.firstName, updatedFirstName)
          XCTAssertEqual(user.address, updatedAddress)
          XCTAssertEqual(user.role, updatedRole)
        } catch { }
      }
}
```

This format improves clarity and encourages collaboration between developers, QA, and non-technical stakeholders by aligning tests with feature expectations.

### Benefits

- **Improved Readability:** The structure helps make test cases egasier to understand.
- **Documentation:** Tests double as documentation for the expected behavior of features.
- **Change Resilience:** Focusing on behavior rather than implementation details makes tests more robust to refactoring.

# How to run tests

## 1. Create a Test Docker Container

To set up a MongoDB container for testing purposes, run the following Docker command:

```bash
docker run --name <NAME_OF_YOUR_CHOICE>-test \
  -e MONGO_INITDB_DATABASE=vapor \
  -p 27017:27017 -d mongo
```

This will start a MongoDB container named <NAME_OF_YOUR_CHOICE>-test and expose it on port 27017. The container will be preconfigured with a vapor database to be used by your API during testing.

## 2. Run the Tests

Use the following command:

```bash
swift test
```

This will run all the test cases defined in the Tests folder of your project.

## 3. Run the Application Locally (Optional)

To run the Medscope API locally (for example, to interact with the API or manually test endpoints), you can start the application by running the following command:

swift run

This will build and run the Vapor app locally, allowing you to interact with the API on your local machine (usually available at http://localhost:8080).

By following these steps, you can set up and test your Swift Vapor API locally with Docker and Swift’s built-in testing tools.

# Exportation

## Export Test Results to a .txt file

Swift’s `swift test` command supports output in different formats, but the one needed here, is the .txt format.

### 1. TXT Output

You can run the tests and export the results in .txt format and specifying the output file.
In order to document the tests, we need to make sure xcpretty is installed :

```bash
gem install xcpretty
```

```bash
mkdir -p test_reports
swift test --enable-test-coverage | xcpretty > test_reports/report.txt
```

This will save the results in a result.txt file correctly formatted.

### 2. Document the test results

Generate the test report with the following script :

```bash
python3 generate_test_report.py
```

The resulting file will be created in the `test_report` folder created in the step above.

# Run Tests on a Specific Folder or File ( optional )

## 1. Test a Specific Folder

If you have a folder within your Tests directory and want to run only the tests inside that folder, you can specify the folder path when running the swift test command.
**Example:**

```bash
swift test --filter MyTests/MySpecificFolder
```

This will run only the tests inside the MySpecificFolder folder.

## 2. Test a Specific File

You can also specify a single test file to run, instead of the entire test suite.
Example:

```bash
swift test --filter MyTests/MySpecificTest.swift
```

This will run only the tests in the specified file MySpecificTest.swift.

**Example Scenario**

If your test structure is something like this:

```bash
Tests/
│
├── AppTests/
│ ├── MySpecificFolder/
│ ├── MySpecificTest.swift
│ └── AnotherTest.swift
```

You can run tests for just MySpecificFolder or MySpecificTest.swift:

- For folder:

```
swift test --filter MyTests/MySpecificFolder
```

- For specific test file:

```
swift test --filter MyTests/MySpecificTest.swift
```

**Note**
• `--filter` works by matching the name of the test target, class, or method. This gives you fine-grained control over what tests to run.
• Ensure the path you provide is relative to the Tests directory, and that it corresponds to the test target or class names.

This method allows you to focus on a subset of tests without running the entire test suite.

# Conclusion

You can easily export Swift test results to plain text format when running tests in the terminal, which can be useful for logging, reporting, or integrating with CI/CD pipelines.
