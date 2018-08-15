import Vapor
import HTTP
import AuthProvider 

/// Here we have a controller that helps facilitate
/// RESTful interactions with our Posts table
final class UserController: ResourceRepresentable {
    
    //SignIn
    func signIn(_ req: Request) throws -> ResponseRepresentable {
        
        // require that the request body be json
//        guard let data = req.json else {
//            throw Abort(.badRequest)
//        }
//        
//        if let user = try User.makeQuery().filter(User.Keys.email, data[User.Keys.email]).first() {
//            let ver = User.passwordVerifier
//            if (User.passwordVerifiertry?.verify(password: user.password.makeBytes(), matches: (data[User.Keys.password]?.string?.makeBytes())!))! {
////            if user.validatePassword(passwd: (data[User.Keys.password]?.string)!) == true {
//                return try! Response(status: .ok, json: ["Message": "SignIn -> Generate Token"])
//            } else {
//                return try! Response(status: .badRequest, json: ["Message": "Bad Password"]) 
//            }
//        }
        return try! Response(status: .badRequest, json: ["Message": "User not exist"]) 
    }

    /// When users call 'GET' on '/user'
    /// it should return an index of all available users
    func index(_ req: Request) throws -> ResponseRepresentable {
        return try User.all().makeJSON()
    }
    
    /// When consumers call 'POST' on '/user' with valid JSON
    /// construct and save the user
//    func register(_ req: Request) throws -> ResponseRepresentable {
//        // require that the request body be json
//        guard let json = req.json else {
//            throw Abort(.badRequest)
//        }
//        
//        // initialize the name and email from
//        // the request json
//        let user = try User(json: json)
//        
//        // ensure no user with this email already exists
//        guard try User.makeQuery().filter("email", user.email).first() == nil else {
//            throw Abort(.badRequest, reason: "A user with that email already exists.")
//        }
//        
//        // require a plaintext password is supplied
//        guard let password = json["password"]?.string else {
//            throw Abort(.badRequest)
//        }
//        
//        // hash the password and set it on the user
//        user.password = try self.hash.make(password.makeBytes()).makeString()
//        
//        // save and return the new user
//        try user.save()
//        return user
        
//        let user = try req.user()
//        
//        if try User.makeQuery().filter(User.Keys.email, user.email).first() == nil  {
//            try user.save()
//            return Response(status: .ok, body: user.makeBody())
//        }
//        
//        return Response(status: .badRequest, body: "User exist")
//    }
    
    /// When the consumer calls 'GET' on a specific resource, ie:
    /// '/user/13rd88' we should show that specific user
    func show(_ req: Request, user: User) throws -> ResponseRepresentable {
        return user
    }
    
    /// When the consumer calls 'DELETE' on a specific resource, ie:
    /// 'user/l2jd9' we should remove that resource from the database
    func delete(_ req: Request, user: User) throws -> ResponseRepresentable {
        try user.delete()
        return Response(status: .ok)
    }
    
    /// When the consumer calls 'DELETE' on the entire table, ie:
    /// '/user' we should remove the entire table
    func clear(_ req: Request) throws -> ResponseRepresentable {
        try User.makeQuery().delete()
        return Response(status: .ok)
    }
    
    /// When the user calls 'PATCH' on a specific resource, we should
    /// update that resource to the new values.
    func update(_ req: Request, user: User) throws -> ResponseRepresentable {
        // See `extension User: Updateable`
        try user.update(for: req)
        
        // Save an return the updated user.
        try user.save()
        return user
    }
    
    /// When a user calls 'PUT' on a specific resource, we should replace any
    /// values that do not exist in the request with null.
    /// This is equivalent to creating a new User with the same ID.
    func replace(_ req: Request, user: User) throws -> ResponseRepresentable {
        // First attempt to create a new User from the supplied JSON.
        // If any required fields are missing, this request will be denied.
        let new = try req.user()
        
        // Update the user with all of the properties from
        // the new user
        user.firstName = new.firstName
        user.lastName = new.lastName
        user.avatar = new.avatar
        user.birthDay = new.birthDay
        
        try user.save()
        
        // Return the updated user
        return user
    }
    
    /// When making a controller, it is pretty flexible in that it
    /// only expects closures, this is useful for advanced scenarios, but
    /// most of the time, it should look almost identical to this 
    /// implementation
    func makeResource() -> Resource<User> {
        return Resource(
            index: index,
//            store: register,
            show: show,
            update: update,
            replace: replace,
            destroy: delete,
            clear: clear
        )
    }
}


/// Since UserController doesn't require anything to 
/// be initialized we can conform it to EmptyInitializable.
///
/// This will allow it to be passed by type.
extension UserController: EmptyInitializable { }
