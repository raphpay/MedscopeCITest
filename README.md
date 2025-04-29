# SW_PRACTICES_MEDSCOPE_API

# Software Practices : Medscope API

Medscope API is a software solution designed to manage the database of all other Medscope software objects, ensuring seamless tracking and compliance through robust data handling.

## I. Installation

### I.1 Prerequisites

- A Mac running on macOS 15 Sequoia ( or higher )
- Install Swift (version: 5.8 or higher)
- Install Swift Package Manager (SPM), included with Swift.
- Install the latest version of [git](https://git-scm.com/downloads)
- Install the IDE of your choice ( optional but recommanded ):
  - [Xcode](https://developer.apple.com/xcode/)
  - [Visual Studio Code](https://code.visualstudio.com/)
- Install Docker to run a MongoDB container ([Download Docker](https://www.docker.com/get-started)).

### I.2 Installing APIMed on Your Workstation

To install the application locally:

- Be invited to the project’s [GitHub repository](https://github.com/glad-medical/APIMed) by the project lead.
- Clone the repository into your workspace using:
  ```bash
  git clone https://github.com/glad-medical/APIMed.git
  ```
- Navigate to the project’s root folder:
  ```bash
  cd APIMed
  ```
- Resolve and download dependencies using Swift Package Manager:
  ```bash
  swift package resolve
  ```

### I.3 Setting Up the Database

Running MongoDB in a Docker Container

To set up MongoDB using Docker:

1. Run the following command to initialize a MongoDB container:

```bash
docker run --name <NAME_OF_YOUR_DB> \
-e MONGO_INITDB_DATABASE=vapor \
-p 27017:27017 -d mongo
```

2. Verify that the container is running:

```bash
docker ps
```

### I.4 Launching the Application

Running the Application Locally

#### 1. Build and run the application:

```bash
swift build
swift run
```

## II. Architecture & Best Practices

### II.1 Style Guide

One of the primary objectives when writing code is to ensure it is readable and easily understood by other developers. To facilitate this, the Swift community follows conventions and recommendations, such as the [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/). Here are some of the most important conventions:

#### Naming Conventions

| Type                    | Convention                                                                  |
| ----------------------- | --------------------------------------------------------------------------- |
| Variables and Functions | `camelCase` - begin with a lowercase letter and capitalize subsequent words |
| Constants               | `MAX_CONNECTIONS` - uppercase with underscores                              |
| Classes and Structs     | `PascalCase` - capitalize the beginning of each word, without punctuation   |
| Enums                   | `PascalCase` for type names, and `camelCase` for cases                      |

#### Comments and Documentation

##### Comments :

It can be helpful to write comments to explain parts of your code that are not immediately obvious.

- Write complete sentences in English.
- Avoid comments that contradict the code. Following Swift’s guidelines, a comment that contradicts the code is worse than no comment at all.
- Use comments sparingly. Swift’s clean syntax encourages writing self-explanatory code.

##### Documentation Comments

Swift supports special comments for documentation purposes using `///`. These are placed above classes, methods, or properties and can generate documentation using tools like [Jazzy](https://github.com/realm/jazzy).

Documentation comments should use a clear, concise structure to describe functionality, input parameters, and expected output. Follow the format below:

```swift
/// Searches for a user by a given ID.
///
/// - Parameter id: The unique identifier for the user.
/// - Returns: A `User` object if found, or `nil` if no user exists with the provided ID.
func searchUser(byID id: String) -> User? {
    // Implementation here...
}
```

For modules or files critical to the system, include a criticality level to indicate required levels of testing and validation. Example:

```swift
///
/// Module: Infrastructure.Database
/// Criticality Level: 2 (High)
/// Description: Handles connections and operations for the MongoDB database.
///
```

#### Other Important Conventions:

Refer to the Swift.org guidelines: [Swift.org API Design Guidelines](https://swift.org/documentation/api-design-guidelines/).

#### Coding Practices

- Use `guard` statements for early exits when handling optionals or checking preconditions.
- Prefer `struct` over `class` unless reference semantics are explicitly needed.

#### Indentation and Line Length

- Use **4 spaces** for indentation.
- Keep line lengths to a maximum of **100 characters** for better readability.

---

This section ensures all team members write maintainable, consistent, and well-documented code, facilitating easier collaboration and reducing technical debt.

### II.2 Best Practices

We follow standard development best practices. Here are some important principles to keep in mind when writing code for a Swift Vapor application:

#### Explicit Naming

Variables, functions, classes, and modules should have explicit names and should never use abbreviations. Below are two examples of functions that determine if a year is a leap year or not:

```diff
- func adjust(value: Int) -> Bool {
-     return (value % 4 == 0) && (value % 100 != 0 || value % 400 == 0)
- }
```

In this example, the function name and its argument are not explicit. While the logic implemented is compact and fits into one line, it’s not clear what the function does just by reading it.

Here’s an improved version:

```diff
+ func isLeapYear(for year: Int) -> Bool {
+     // Leap years are all multiples of 4
+     if year % 4 != 0 {
+         return false
+     }
+
+     // However, century years are not leap years except 1600, 2000, 2400, etc.
+     if year % 100 == 0 {
+         return year % 400 == 0
+     }
+
+     // All other results are true.
+     return true
+ }
```

#### Typing

Swift is a strongly-typed language. Always leverage Swift’s type system to improve clarity and reduce potential bugs. Explicitly define parameter and return types for every function, even when they could be inferred.

Without explicit types:

```diff
- func isLeapYear(_ year) -> Bool {
-     ...
- }
```

With explicit types:

```diff
+ func isLeapYear(for year: Int) -> Bool {
+     ...
+ }
```

This enhances readability and ensures the code is self-documenting.

#### SOLID Principles

Cleaner designs are easier to understand, maintain, modify, and test. By following the SOLID principles, we achieve a cleaner design in Swift Vapor applications.

The SOLID principles are:

- Single Responsibility Principle: Each class or struct should have one, and only one, reason to change.
- Open/Closed Principle: Classes should be open for extension but closed for modification.
- Liskov Substitution Principle: Subtypes must be substitutable for their base types.
- Interface Segregation Principle: Keep interfaces small and focused on specific clients.
- Dependency Inversion Principle: High-level modules should not depend on low-level modules. Both should depend on abstractions.

#### Additional Practices for Swift Vapor

1. Use Fluent Properly: Define models and migrations cleanly. Always validate data at the model and request level.
2. Prefer guard for Early Exits: Use guard statements to handle errors and unwrap optionals for clearer code.
3. Leverage Vapor’s Middleware: Use middleware to handle repetitive tasks like authentication and logging.
4. Write Tests: Ensure every route and middleware is tested for both success and failure cases.

### II.3 Design Pattern and system architecture

This paragraph outlines the architecture and design patterns employed in building a CRUD backend application using the Swift Vapor framework. Vapor is a server-side Swift web framework that provides a modular and highly customizable structure for building web applications.

#### System Architecture

The backend application follows a layered architecture. Below is a breakdown of the key layers:

1. **Controller Layer**:

- Handles HTTP requests and responses.
- Responsible for routing and calling the appropriate service methods.
- Uses Vapor’s built-in RouteCollection for organizing routes.

2. **Service Layer**:

- Encapsulates business logic.
- Acts as an intermediary between the controller and data access layers.
- Ensures data validation and orchestration of complex operations.

3. **Repository Layer**:

- Handles data access.
- Abstracts the database interaction to provide a clean interface for querying and updating data.
- Uses Fluent, Vapor’s ORM, to perform database operations.

4. **Model Layer**:

- Defines the structure of the application's data.
- Implements Vapor's Model protocol for database integration.
- Ensures relationships, constraints, and serialization requirements are met.

#### Design Patterns

1. **MVC (Model-View-Controller)**:

- Model: Represents the data layer and conforms to Content and Model for database interactions.
- Controller: Manages routes and processes incoming requests.
- View: non applicable

2. **Repository Pattern**:

- Provides an abstraction over database operations.
- Improves code maintainability by decoupling the business logic from the persistence logic.

3. **Service Pattern**:

- Consolidates business logic into service classes, keeping controllers thin.
- Promotes reusability and testability of code.

4. **Dependency Injection**:

- Leverages Vapor’s LifecycleHandler and Services to register and resolve dependencies.
- Makes the application modular and easier to test.

**Example**

Let's take as an example a feature of the APIMed software: create a table that store the version of the different softwares of Medscope.

### Model

In a Vapor application, a model represents the data structure, typically backed by a database. We’ll define a model for the version log that conforms to Model, Content, and uses Fluent for database interactions.

```swift
import Fluent
import Vapor

final class VersionLog: Model, Content, @unchecked Sendable {
    static let schema = VersionLog.v20240618.schemaName

    @ID(key: .id)
    var id: UUID?

    @Field(key: VersionLog.v20240618.interface)
    var interface: String

    @Field(key: VersionLog.v20240618.api)
    var api: String

    @Field(key: VersionLog.v20240618.calculator)
    var calculator: String

    @OptionalField(key: VersionLog.v20240618.submissionPlatform)
    var submissionPlatform: String?

    init() { }

    init(id: UUID? = nil,
         interface: String,
         api: String,
         calculator: String,
         submissionPlatform: String? = nil
    ) {
        self.id = id
        self.interface = interface
        self.api = api
        self.calculator = calculator
        self.submissionPlatform = submissionPlatform
    }
}
```

Explanation:
• `@ID(key: .id)`: Automatically generates a unique ID for each version log.
• `@Field(key: v20240618.interface)`: This field represents the interface column in the database and uses a FieldKey to ensure consistency.
• `@OptionalField(key: v20240618.submissionPlatform)`: This field is optional, which means it can contain a nil value.
• `v20240618`: A struct containing FieldKeys to define the names of the database fields. This ensures that the field names are consistent and easily refactorable.
• `init()`: Provides an initializer for creating new version logs.

### Migration

A migration defines how to create or modify the database schema for your model. Below is an example of a migration for creating a version_logs table in the database.

```swift
import Fluent

struct CreateVersionLog: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database
            .schema(VersionLog.v20240618.schemaName)
            .id()
            .field(VersionLog.v20240618.interface, .string, .required)
            .field(VersionLog.v20240618.api, .string, .required)
            .field(VersionLog.v20240618.calculator, .string, .required)
            .field(VersionLog.v20240618.submissionPlatform, .string, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database
            .schema(VersionLog.v20240618.schemaName)
            .delete()
    }
}
```

Explanation:
• `database.schema(VersionLog.v20240618.schemaName)`: Defines the schema for the version_logs table.
• `.id()`: Creates an auto-incrementing ID as the primary key.
• `.field("field_name", .type, .required)`: Specifies fields for the schema.
• `create()`: Creates the table when the migration is applied.
• `revert()`: Deletes the table if the migration is reverted.

To apply the migration, you can run the following in your terminal:

```bash
swift run App migrate
```

### Controller

The controller handles HTTP requests related to the version log. It defines actions for creating, reading, and updating version logs.

```swift
struct VersionLogController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let routes = routes.grouped("api").grouped(APIKeyCheckMiddleware())

        routes
            .group(
                tags: TagObject(
                    name: "versionLogs",
                    description: "Everything about version log"
                )
            ) { routes in
                let tokenAuthMiddleware = Token.authenticator()
                let guardAuthMiddleware = User.guardMiddleware()
                let tokenAuthGroup = routes.grouped(tokenAuthMiddleware, guardAuthMiddleware)
                // POST
                tokenAuthGroup.post(use: create)
                    .openAPI(
                        summary: "Create a new version log",
                        description: "Create a new version log. Could only be one in the API",
                        body: .type(VersionLog.Input.self),
                        contentType: .application(.json),
                        response: .type(VersionLog.self),
                        responseContentType: .application(.json)
                    )
                // GET
                tokenAuthGroup.get(use: get)
                    .openAPI(
                        summary: "Get the version log",
                        response: .type(VersionLog.self),
                        responseContentType: .application(.json)
                    )
                    .response(statusCode: .notFound, description: "Version log not found")

                // UPDATE
                tokenAuthGroup.put(use: update)
                    .openAPI(
                        summary: "Update the version log",
                        body: .type(VersionLog.UpdateInput.self),
                        contentType: .application(.json),
                        response: .type(VersionLog.self),
                        responseContentType: .application(.json)
                    )
                    .response(statusCode: .notFound, description: "Version log not found")
            }
    }

    // MARK: - CREATE
    @Sendable
    func create(req: Request) async throws -> VersionLog {
        let input = try req.content.decode(VersionLog.Input.self)

        if try await !VersionLog.query(on: req.db).all().isEmpty {
            throw Abort(.conflict, reason: "conflict.versionLogAlreadyExists")
        }

        let versionLog = input.toModel()
        try await versionLog.save(on: req.db)

        return versionLog
    }

    // MARK: - READ
    @Sendable
    func get(req: Request) async throws -> VersionLog {
        try await get(on: req)
    }

    // MARK: - UPDATE
    @Sendable
    func update(req: Request) async throws -> VersionLog {
        guard let versionLog = try await VersionLog.query(on: req.db).first() else {
            throw Abort(.notFound, reason: "notFound.versionLog")
        }

        let updateInput = try req.content.decode(VersionLog.UpdateInput.self)
        let updatedVersionLog = updateInput.update(versionLog)

        try await updatedVersionLog.update(on: req.db)

        return updatedVersionLog
    }
}
```

Explanation:

- Routes Setup: The controller handles routes under /api and applies middleware for authentication and authorization.
- Create Route: The create function is responsible for creating a new version log. It checks if a version log already exists, and if not, it saves a new version log.
- Get Route: The get function retrieves the current version log from the database.
- Update Route: The update function updates an existing version log with new data.

### DTO

The DTO (Data Transfer Object) defines the structure of the data that is passed between the client and the server. In this case, we define an Input struct to handle the incoming data when creating or updating a VersionLog. We also provide a method to convert the DTO into a model.

```swift
import Fluent
import Vapor

// MARK: - Input DTO
extension VersionLog {
    struct Input: Content {
        let interface: String
        let api: String
        let calculator: String
        let submissionPlatform: String?

        // Converts the Input DTO to a VersionLog model
        func toModel() -> VersionLog {
            return VersionLog(interface: interface, api: api, calculator: calculator, submissionPlatform: submissionPlatform)
        }
    }
}
```

Explanation:

- The `Ìnput` struct conforms to Content to handle the JSON data transfer.
- The `toModel()` method converts the input data into a `VersionLog` model. This method ensures that we can easily convert incoming data into a database model that conforms to the schema.

### Field Keys

Field Keys provide a type-safe and consistent way to reference database columns in your models. By using Field Keys, you can avoid hardcoding column names and instead rely on constants that can be reused throughout your application. This reduces the risk of errors due to typos and makes your code more maintainable and easier to refactor.

In this section, we define the FieldKey constants in a structured way, which will be used in the model and migrations for consistency.

```swift
import Fluent

extension VersionLog {
    // MARK: - Versioned Field Keys
    enum v20240618 {
        static let schemaName = "versionLogs"  // Table name

        // Field keys for the database columns
        static let id = FieldKey(stringLiteral: "id")
        static let interface = FieldKey(stringLiteral: "interface")
        static let api = FieldKey(stringLiteral: "api")
        static let calculator = FieldKey(stringLiteral: "calculator")
        static let submissionPlatform = FieldKey(stringLiteral: "submissionPlatform")
    }
}
```

Explanation:

- `FieldKey` Constants: The FieldKey constants represent the actual column names in the database. By using these constants, you can reference fields in a type-safe way instead of using string literals throughout your code.
- Versioning: The enum `v20240618` represents a version of the schema. This allows you to manage schema changes over time. If you change a column name, you only need to modify it in this enum and not throughout your entire codebase.
- Schema Name: v20240618.schemaName defines the table name in the database, making it easy to reference and modify if needed.

#### Summary

In this example, we:

1. **Created a VersionLog model**: This model represents a version log in the database, with properties like `interface`, `api`, `calculator`, and `submissionPlatform`. The model uses Fluent’s `@Field` and `@OptionalField` property wrappers to map these properties to the respective database columns, ensuring type safety and consistency.

2. **Defined a migration**: We created a migration to define the structure of the `versionLogs` table in the database. This migration uses the `FieldKey` constants to reference the column names, providing a consistent, type-safe way to define and manage the schema.

3. **Built a VersionLogController**: This controller handles the HTTP requests for creating, reading, and updating version logs in the API. It provides the full CRUD functionality by using the `POST`, `GET`, and `PUT` HTTP methods. The controller utilizes the `VersionLog.Input` DTO (Data Transfer Object) for handling incoming data and converting it into the `VersionLog` model.

4. **Implemented DTO (Data Transfer Object)**: The `Input` struct is used to handle incoming data, allowing easy conversion of the request payload into a `VersionLog` model. This structure ensures that the data can be validated and manipulated before interacting with the database.

5. **Used Field Keys**: To maintain type safety and avoid hardcoding column names, we introduced `FieldKey` constants for each database column. This approach centralizes field names, reducing the risk of errors and improving maintainability.

This setup provides a full CRUD (Create, Read, Update, Delete) functionality for managing version logs within your Vapor application. The use of Field Keys, DTOs, and migrations ensures that the application is scalable, type-safe, and easy to maintain. You can now interact with this API to manage version logs via HTTP requests.

### II.4 Final Architecture

The resulting organization of the project incorporates the various layers explained above, but adds a separation into packages according to the relevant domain:

```bash
├── Sources
│   ├── App
│   │   ├── Controllers
│   │   │   └── VersionLogController.swift
│   │   ├── DTOs
│   │   │   └── VersionLogDTO.swift
│   │   ├── Enums
│   │   │   └── VersionLog+Status.swift
│   │   ├── Extensions
│   │   │   └── String+Ext.swift
│   │   ├── FieldKeys
│   │   │   └── VersionLog+FieldKeys.swift
│   │   ├── Jobs
│   │   ├── Middlewares
│   │   │   └── VersionLogMiddleware.swift
│   │   ├── Migrations
│   │   │   └── CreateVersionLog.swift
│   │   ├── Models
│   │   │   └── VersionLog.swift
│   │   ├── Utils
│   │   │   ├── Validation
│   │   │   │   └── VersionLogValidation.swift
│   ├── configure.swift
│   ├── entrypoint.swift
│   ├── routes.swift
├── Tests
│   ├── AppTests
│   │   └── VersionLogsControllerTests.swift
```

## III. Development Process

### III.1 Requirements specification

In our development process, specifications are captured and tracked through GitHub Issues. These issues ensure clarity and consistency across the team. We use three types of issues: **Bug**, **Feature**, and **Tech**. Each type has an associated issue template designed to standardize the information needed for effective planning and execution.Additionally, every issue is assigned a criticality rating to assess its potential impact on the results produced by the software, ensuring risk management is integral to the development process.

#### III.1.a Issue types and specification

- **Bug**:

  - **Purpose**: Document unexpected behavior, system errors, or vulnerabilities.
  - **Template Fields**:
    - **Description**: Briefly describe the issue.
    - **Steps to Reproduce**: Detailed steps to recreate the issue.
    - **Specific Case**: Specific patient file associated with the bug if relevant.
    - **Expected Behavior**: What should happen.
    - **Actual Behavior**: What actually happens.
    - **Screenshots**: if applicable.
    - **Workaround**: Temporary solutions or mitigations (if available).
    - **Criticality** Rating: Assessment of the potential impact on computed results.

- **Feature**:

  - **Purpose**: Define new functionality or enhancements.
  - **Template Fields**:
    - **Summary**: A concise overview of the feature.
    - **Acceptance Criteria**: Clear conditions for completion.
    - **Mockups/References**: Attach visuals or relevant links (if applicable).
    - **Dependencies**: Other issues, teams, or steps required.
    - **Criticality Rating**: Assessment of the potential impact on scientific results.

- **Tech**:
  - **Purpose**: Address technical tasks such as tests, documentation, maintenance, or cybersecurity issues.
  - **Template Fields**:
    - **Objective**: What needs to be achieved.
    - **Context**: Why this task is necessary.
    - **Task List**: Clear, actionable steps.
    - **Impact**: How this will affect the system or process.
    - **Dependencies**: Relevant links to other issues or pull requests.
    - **Security Considerations**: Any potential cybersecurity concerns or how this task enhances security.

### III.2 Milestone Planning

Milestone planning is a collaborative process where the project manager and developers work together to define the scope for the upcoming milestone, which is represented by a specific target date. This ensures clear goals and effective allocation of tasks within the development cycle.

#### Steps in Milestone Planning:

- **Selecting Issues**:
  - The team reviews the existing pool of issues, considering the project’s priorities, their complexity, and the criticality rating.
  - Issues deemed essential for the milestone are selected.
- **Specification Review**:
  - The team collectively reviews each selected issue to ensure that all necessary information is present and clear. This includes:
    - Complete and accurate descriptions.
    - Clearly defined acceptance criteria.
    - Links to dependencies, if any.
    - A properly assigned criticality rating.
- **Assignment**:
  - Each selected issue is assigned to one or more developers responsible for its completion within the milestone timeline.
- **Milestone Confirmation**:
  Once all issues are reviewed and updated as needed, the milestone plan is finalized, and work proceeds according to the agreed timeline.

This structured approach ensures that each milestone is realistic, well-defined, and aligned with the project's overall goals.

### III.3 Development

Once the issue has been assigned, the developer works on his workstation in a git branch specific to that issue.

- Find the name of the branch : In Github, on the issue page : Development > Create a branch > Copy branch name
- Pull the latest version of the `main` branch locally and create a new branch
  ```gitbash
  > git checkout main
  > git pull -r
  > git chekout {name_of_the_branch}
  ```
- Write code that adheres to the project's style and architecture guidelines
- Ensure that the feature or bugfix works correctly and meets all the issues' specifications and acceptance criteria
- Run all tests locally ( see the [README.md](https://github.com/glad-medical/APIMed/blob/main/Tests/AppTests/README.md) file located in the Tests/AppTests folder )
- Push the branch to the remote repository
  ```bash
  > git add .
  > git commit -m "{appropriate commit message}"
  > git push
  ```

### III.4 Pull request

- Create a pull request on GitHub : base branch is `main` and compared branch is the branch with new development.

### III.5 Review

- Check adherence to best practices and architectural rules
- Verify that comments are written/updated
- Ensure that comments are relevant

### III.5 Merge

- Merge the given branch on the main branch via the github pull request interface. Only one commit should be added to the main branch. This commit name must begin with the feature id or the bugfix id like `[FEAT-119] - Material properties personalization according to patient age`
- If the name of the branch was created following the described process, merging the branch should automatically close the related issue. However, It's up to the person who merges the branch to ensure that the related issue is now closed.

## IV. Software release

### IV.1 Versioning

Before deploying a new version to production, the developer must add a tag to the specific commit on the main branch that will be tested and potentially released. This tag follows a naming convention that reflects the release stage. For example, for a release candidate, the tag would be **RC-V1.0.2**. RC stands for Release Candidate.

Once all integration tests and software system tests have been completed and the version is confirmed ready for production, the final release tag **RELEASE-V1.0.2** will be applied to the same commit. This ensures clear version tracking and consistency in our deployment process.

We use the semantic versioning to manage our software release. We use a three part version number format : **MAJOR.MINOR.PATCH**.

**MAJOR Version**: This number is incremented when there are incompatible changes that affect other parts of Medscope System. A major release indicates that significant new features have been added or existing features have changed in a way that may break backward compatibility. For example, moving from version 1.0.0 to 2.0.0 signifies that developers should review their integration with the software due to potential breaking changes.

**MINOR Version**: This number is incremented when new features are added in a backward-compatible manner. This means that existing functionality remains intact while new capabilities are introduced. For instance, updating from version 1.0.0 to 1.1.0 means users can adopt the new features without worrying about breaking existing functionality.

**PATCH Version**: This number is incremented when backward-compatible bug fixes are introduced. These fixes address minor issues or defects within the existing functionality and do not introduce any new features. For example, moving from version 1.0.0 to 1.0.1 indicates that the software has had a minor bug fixed.

For example, in the version **V1.0.2**:

- 1 is the MAJOR version, indicating the first significant release of the software.
- 0 is the MINOR version, indicating there have been no new backward-compatible features added since the last major release.
- 2 is the PATCH version, indicating two bug fixes or minor updates have been made since the last minor or major version.

This approach to versioning helps maintain clarity and predictability in the release process, especially during maintenance and future development.

### IV.2 Release candidate

The release candidate (RC) process occurs after completing a set of issues and serves as a testing phase for the upcoming software release. This phase includes creating a testable version of the software, planning its scope, deploying it in appropriate environments, and conducting extensive manual and system testing.

#### Release Candidate Planning

Before generating the release candidate, the team holds a release candidate planning session to: - Identify Features: List all new functionalities and fixes to include in the release candidate. - Draft the Release Notes (see next chapter)

In github, on APIMed home page, click the `Create new release button`. In the form, create a new tag `RC-{release-version-number}-{RC number}`, for example `RC-1.0.0-1` will be the first release candidate for the release `V1.0.0`. Release title will be the same as the tag name. Check the `Set as a pre-release` box. Fill in `release notes` box with release notes produced during release candidate planning. Finally, click the `Publish release` button.

#### Launch test in local environment

Before deploying a new version to production, the developer must test locally the app, and generate a test report. The local test instructions should follow the instructions in [Test/AppTests/Readme.md](https://github.com/glad-medical/APIMed/blob/main/Tests/AppTests/README.md). The test report should be generated, and uploaded to the google drive test result folder.

##### Decision and Iteration

Based on the test and anomaly reports, the project manager reviews the results and decides on the next steps:

- Bug Fixing Cycle: If the manager deems certain issues critical, the development team will address these bugs, and the process of creating a new release candidate restarts. We increment the release candidate number. For example : `RC-1.0.0-1` becomes `RC-1.0.0-2`
- Proceed to Release: If no further fixes are required, the software moves to the release phase, where it is prepared for production deployment.

Before deploying a new version to production, the developer must perform thorough local testing of the application and generate a comprehensive test report. This ensures the stability and reliability of the application in the production environment.

#### Deployment of the Release Candidate

Once the commit has been tested and validated, a TAG is added to mark the specific version, such as RC-1.0.2.

In the working directory used for software testing, the following steps are carried out:

1. Log into the S4A Bastion:

Log into the S4A bastion server, which will provide access to the recette environment:

```bash
ssh -J user@bastion.server.com username@SERVER_ID_ADDRESS -p22
```

2. Pull the Latest Code:

Once logged into the bastion, navigate to the API directory and pull the latest changes from the repository on the production machine:

```bash
cd /srv/www/APIMed
git fetch --all
git checkout APIMED_RC-1.0.0-1
```

3. Build Docker Containers:

   In the directory containing the docker-compose.yml file, build the application using Docker Compose:

   ```bash
   docker compose build
   ```

4. Run the Application:

   Once the Docker containers are built, start the application by running the following command:

   ```bash
   docker compose up -d app
   ```

   This will start your Vapor application in a containerized environment.

This process ensures that the latest version of the application is deployed to recette.

**Rollback Plan**

In case of any issues during the release, a rollback can be performed by following these steps:

Navigate to the directory used for software testing.
Checkout the previous TAG:

```bash
git checkout APIMED_RC-1.0.0-0
docker compose run --rm app migrate --revert
docker compose build
docker compose up app
```

This ensures that if any issues arise after deployment, we can quickly revert to the previous stable version.

### IV.3 Release Notes

Release Notes are written during RC planning and can be updated during the bug fixing cycle if needed. The release notes ares structured as follows:

```
- key updates :
  - new features
  - enhancements
  - resolved bugs
  - known limitations
  - new soup disclosure
- internal notes:
  - version changes of SBOM
  - compilation method / version
  - script to rollback to previous version
```

### IV.4 Release

Once the RC has been tested and validated, we are ready for release.
In github, on APIMed home page, click the `Create new release button`. In the form, create a new tag `V{release-version-number}`, for example `V1.0.0` will be the first release. Release title will be the same as the tag name. **DO NOT** check the `Set as a pre-release` box. Fill in `release notes` box with final release notes. Finally, click the `Publish release` button.

In the release candidate directory the following steps are carried out:

1. Checkout the new TAG:

```bash
>git checkout RELEASE-V1.0.2
```

2. Update the documentation
3. Update the test report
4. Deploy to Production:
   All folders and files src and resources files present in the release candidate directory are copied and pasted into the production directory.

   1. Log into the S4A Bastion:

   Log into the S4A bastion server, which will provide access to the production environment:

   ```bash
   ssh -J user@bastion.server.com username@SERVER_ID_ADDRESS -p22
   ```

   2. Pull the Latest Code:

   Once logged into the bastion, navigate to the API directory and pull the latest changes from the repository on the production machine:

   ```bash
   cd <PATH_TO_DIRECTORY>
   git pull origin main
   git checkout RELEASE-v1.0.2
   ```

   3. Build Docker Containers:

   Navigate to the project directory containing the docker-compose.yml file and build the application using Docker Compose:

   ```bash
   docker compose build
   ```

   4. Run the Application:

   Once the Docker containers are built, start the application by running the following command:

   ```bash
   docker compose up app
   ```

   This will start your Vapor application in a containerized environment.

   This process ensures that the latest version of the application is deployed to recette.

**Rollback Plan**

In case of any issues during the release, a rollback can be performed by following these steps:

Navigate to the directory used for software testing.
Checkout the previous TAG:

```bash
git checkout RELEASE-v1.0.1
docker compose run --rm app migrate --revert
docker compose build
docker compose up app
```

This ensures that if any issues arise after deployment, we can quickly revert to the previous stable version.

Once deployed, the documentation will be accessible at:
[Google Drive - API Folder](https://drive.google.com/drive/folders/133WfR7bkinL-1i3WIphL1A2LY6j-XvC6)
The test coverage report will be available at:
[Google Drive - API Test folder](https://drive.google.com/drive/folders/1HNC5v2n25WnDf6mFpuE4XBAr0h2DUJQK)

### IV.5 Retrieve previous version & Rollback

In a Swift Vapor project, retrieving a previous version and rolling back is simplified with proper versioning and containerized deployments. Using Git for version control and Docker Compose for deployment ensures that rollbacks can be executed efficiently and reliably.
But when rolling back to a previous version in a Swift Vapor application, managing database migrations is a critical aspect.

Steps to Retrieve a Previous Version

1. Identify the Version:

- Use Git to locate the tag or commit hash associated with the version you want to retrieve. Tags like v1.2.0 should clearly indicate stable releases.

- This command shows the applied migrations, allowing you to identify those that need to be reverted.

2. Rollback Database Migrations

- Fluent provides commands to revert specific migrations. For example, to roll back the most recent migration:

```bash
docker compose run --rm app migrate --revert
```

3. Checkout the desired Version:

- Switch to the desired version in the Git repository:

```gitbash
> git checkout v1.2.0
```

4. Build and Deploy the Version:

- Ensure you’re in the project directory where docker-compose.yml is located.
- Build and deploy the specific version using Docker Compose

```bash
docker-compose build
docker-compose up -d app
```

5. Verify the Deployment:

- Ensure the API is running as expected by checking logs or interacting with the endpoints:

```bash
docker-compose logs app
```

This streamlined process ensures that any issues after a deployment can be mitigated by rapidly reverting to a previous stable version.

## V. On Testing

### V.1 Integration Testing

Integration testing focuses on verifying the interactions between different components of the application to ensure they work together as expected. In this context, integration tests evaluate how various routes, database interactions, and middleware function cohesively within the application.

These tests are essential for checking the complete behavior of the application, including validating CRUD (Create, Read, Update, Delete) operations, ensuring proper data flow between the routes and the database, and verifying the correctness of business logic.

In this project, integration tests are used to:
• Test CRUD Operations: Ensuring that creating, retrieving, updating, and deleting data from the database through the API routes works as expected. For example, confirming that a VersionLog can be successfully created, updated, and retrieved through the API.
• Validate Data Integrity: Testing the validation and constraints of the fields in the database. This includes checking that the required fields are properly handled, such as ensuring that non-optional fields like interface, api, and calculator cannot be left empty.
• Check Authentication and Authorization: Verifying that protected routes require proper authentication tokens or user permissions, ensuring that unauthorized users cannot access certain API endpoints.
• Test Error Handling: Simulating edge cases such as missing required fields or invalid data to ensure the application returns appropriate error responses (e.g., 400 Bad Request or 404 Not Found).

Integration tests help identify issues that may not arise in isolated unit tests, such as incorrect configurations, improper network dependencies, or failures in data flow between different components. By simulating real-world usage, they give confidence that the entire system works as expected when integrated.

The development team is responsible for creating and executing integration test scenarios that simulate real-world use cases of the application, including the interactions between API routes, database, and validation logic.

#### How to Write Integration Tests Using the Given-When-Then Structure

Integration tests can also follow the Given-When-Then structure, which ensures that the test setup, actions, and assertions are clearly defined. Here’s how this structure applies to integration testing in a Swift Vapor project:

**Example**: Testing an API Endpoint for Creating a Version Log

```swift
import XCTVapor
@testable import App

final class VersionLogIntegrationTests: XCTestCase {
    var app: Application!

    override func setUpWithError() throws {
        app = Application(.testing)
        try configure(app) // Ensure your app is properly configured for testing
    }

    override func tearDownWithError() throws {
        app.shutdown()
    }

    func testCreateVersionLog() throws {
        // Given: A valid input payload
        let inputPayload = VersionLog.Input(
            interface: "1.0.0",
            api: "1.2.3",
            calculator: "2.0.1",
            submissionPlatform: "3.4.5"
        )

        // When: A POST request is made to the "create version log" endpoint
        try await app.test(.POST, "api/versionLogs") { req in
            try req.content.encode(inputPayload)
            req = Utils.prepareHeaders(apiKey: apiKey, token: token, on: req)
        } afterResponse: { res async in
            // Then: The response should have a status of 200 and return the created VersionLog
            XCTAssertEqual(response.status, .ok)
            do {
              let versionLog = try response.content.decode(VersionLog.self)
              XCTAssertEqual(versionLog.interface, "1.0.0")
              XCTAssertEqual(versionLog.api, "1.2.3")
              XCTAssertEqual(versionLog.calculator, "2.0.1")
              XCTAssertEqual(versionLog.submissionPlatform, "3.4.5")
            } catch { }
        }
    }
}
```

#### Steps for Writing Integration Tests

1. Setup the Test Environment:

- Use Application(.testing) to configure the Vapor app in testing mode.
- Mock dependencies or use a dedicated testing database to isolate the test environment.

2. Given: Define Initial Conditions:

- Prepare the required data, inputs, or configurations. For instance, create a valid request payload or set up necessary database entries.

3. When: Execute the Integration:

- Perform the operation being tested, such as making an HTTP request to an API endpoint or interacting with a service layer.

4. Then: Verify the Outcome:

- Assert the expected behavior by examining the response or verifying the changes in the database.

#### Advantages of Integration Testing

- Realistic Coverage: Tests the interaction between components, providing confidence in the system as a whole.
- Error Detection: Identifies issues that arise from misconfigured dependencies, incorrect routing, or broken connections.
- Improved Reliability: Validates workflows closer to real-world scenarios.

#### Best Practices for Integration Testing

- Use a Test Database: Isolate tests by using an in-memory SQLite database or a dedicated test instance of your database.
- Keep Tests Independent: Ensure tests do not rely on each other to avoid interference.
- Automate Testing: Integrate your tests into a CI/CD pipeline for continuous feedback.

By adopting integration testing alongside unit tests, you ensure that your Vapor application is robust, reliable, and ready to handle complex real-world interactions.

#### How to run unit tests

See the test documentation in the [Tests/AppTests folder](https://github.com/glad-medical/APIMed/blob/main/Tests/AppTests/README.md) of this repository

### V.2 Software system testing

Project managers and testers are responsible for writing test scenarios and carrying out software system tests.
System testing is performed manually by a user according to a predefined test plan (`System Testing Scenarii`). The purpose of this testing phase is to ensure that end-to-end scenarios are functioning correctly, and that the system generates accurate and relevant results for clients. All tests are conducted in the same production environment described earlier—on the production server, with the same configurations and Software of Uncertain Provenance (SOUP) as used in the live environment, but within a separate working directory to avoid any impact on production.

The software test will be considered successful if the following criteria are met:

- All test scenarios pass without issues.
- No regressions are introduced into previously functioning features.
- The results generated by the system are accurate and meet the defined business requirements.
