import Vapor
import FluentProvider
import AuthProvider
import Foundation
import BCrypt
import HTTP

final class User: Model {
    
    let storage = Storage()
    
    // MARK: Properties and database keys
    
    /// The content of the user
    /// First name of the user
    var firstName: String
    /// Last name of the user
    var lastName: String
    /// Icon of the user
    var avatar: String
    /// BirthDay of the user
    var birthDay: String
    /*private(set)*/ var email: String
    /*private(set)*/ var password: String
    

    
    /// The column names for `id` and `content` in the database
    struct Keys {
        static let id = "id"
        static let firstName = "firstName"
        static let lastName = "lastName"
        static let avatar = "avatar"
        static let birthDay = "birthDay"
        static let email = "email"
        static let password = "password"
    }
    
    /// Creates a new User
    init(firstName: String, lastName: String, avatar: String, birthDay: String, email: String, password: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.avatar = avatar
        self.birthDay = birthDay
        self.email = email
        self.password = password
    }
    
    
    // MARK: Fluent Serialization
    
    /// Initializes the User from the
    /// database row
    init(row: Row) throws {
        firstName = try row.get(User.Keys.firstName)
        lastName = try row.get(User.Keys.lastName)
        avatar = try row.get(User.Keys.avatar)
        birthDay = try row.get(User.Keys.birthDay)
        email = try row.get(User.Keys.email)
        password = try row.get(User.Keys.password)
    }
    
    // Serializes the User to the database
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(User.Keys.firstName, firstName)
        try row.set(User.Keys.lastName, lastName)
        try row.set(User.Keys.avatar, avatar)
        try row.set(User.Keys.birthDay, birthDay)
        try row.set(User.Keys.email, email)
        try row.set(User.Keys.password, password)
        return row
    }
    
//    func validatePassword(passwd : String) -> Bool {
//        let hash = BCryptHasher(cost: 32)
//        let enteredPass = try hash.make(passwd.makeBytes()).makeString() 
//        return self.password == enteredPass
//    }
}


// MARK: Fluent Preparation

extension User: Preparation {
    /// Prepares a table/collection in the database
    /// for storing Users
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(User.Keys.firstName)
            builder.string(User.Keys.lastName)
            builder.string(User.Keys.avatar)
            builder.string(User.Keys.birthDay)
            builder.string(User.Keys.email)
            builder.string(User.Keys.password)
        }
    }
    
    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: JSON

// How the model converts from / to JSON.
// For example when:
//     - Creating a new User (POST /users)
//     - Fetching a user (GET /users, GET /users/:id)
//
extension User: JSONConvertible {
    convenience init(json: JSON) throws {
        self.init(firstName: try json.get(User.Keys.firstName), lastName: try json.get(User.Keys.lastName), avatar: try json.get(User.Keys.avatar), birthDay: try json.get(User.Keys.birthDay), email: try json.get(User.Keys.email), password: try json.get(User.Keys.password))
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(User.Keys.id, id)
        try json.set(User.Keys.firstName, firstName)
        try json.set(User.Keys.lastName, lastName)
        try json.set(User.Keys.avatar, avatar)
        try json.set(User.Keys.birthDay, birthDay)
        try json.set(User.Keys.email, email)
        try json.set(User.Keys.password, password)
        return json
    }
}

// MARK: HTTP

// This allows User models to be returned
// directly in route closures
extension User: ResponseRepresentable { }

// MARK: Update

// This allows the User model to be updated
// dynamically by the request.
extension User: Updateable {
    // Updateable keys are called when `user.update(for: req)` is called.
    // Add as many updateable keys as you like here.
    public static var updateableKeys: [UpdateableKey<User>] {
        return [
            // If the request contains a String at key "content"
            // the setter callback will be called.
            UpdateableKey(User.Keys.firstName, String.self) { user, content in
                user.firstName = content
            },
            UpdateableKey(User.Keys.lastName, String.self) { user, lastName in
                user.lastName = lastName
            },
            UpdateableKey(User.Keys.avatar, String.self) { user, avatar in
                user.avatar = avatar
            },
            UpdateableKey(User.Keys.birthDay, String.self) { user, birthDay in
                user.birthDay = birthDay
            },
            UpdateableKey(User.Keys.email, String.self) { user, email in
                user.email = email
            },
            UpdateableKey(User.Keys.password, String.self) { user, password in
                user.firstName = password
            }
        ]
    }
}


//Auth
// store private variable since storage in extensions
// is not yet allowed in Swift
private var _userPasswordVerifier: PasswordVerifier? = nil

extension User: PasswordAuthenticatable {
    public static let hasher = BCryptHasher(cost: 11) // (1)
//    public static let passwordVerifier: PasswordVerifier? = User.hasher(2)
    
    var hashedPassword: String? {
        return password
    }
    
    public static var passwordVerifier: PasswordVerifier? {
        get { return _userPasswordVerifier }
        set { _userPasswordVerifier = newValue }
    }
    
}


// MARK: Request
extension Request {
    /// Convenience on request for accessing
    /// this user type.
    /// Simply call `let user = try req.user()`.
    func user() throws -> User {
        return try auth.assertAuthenticated()
    }
}

// MARK: Token
// This allows the User to be authenticated
// with an access token.
extension User: TokenAuthenticatable {
    typealias TokenType = Token
}



//extension User: PasswordAuthenticatable

extension User: BodyRepresentable {
    func makeBody() -> Body {
        let data = try? JSONSerialization.data(withJSONObject: ["data": self.makeJSON()], options: [])
        return .data(data!.makeBytes())
    }
}


