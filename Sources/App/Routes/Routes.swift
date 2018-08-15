import Vapor
import AuthProvider


extension Droplet {
    func setupRoutes() throws {

        try setupUnauthenticatedRoutes()
        try setupTokenProtectedRoutes()
        
//        post("signin") {req in 
//            try UserController().signIn(req)
//        }
        
        
    }
    
    
    /// Sets up all routes that can be accessed
    /// without any authentication. This includes
    /// creating a new User.
    private func setupUnauthenticatedRoutes() throws {
        
        // response to requests to /info domain
        // with a description of the request
        get("info") { req in
            return req.description
        }
        
        // create a new user
        //
        // POST /users
        // <json containing new user information>
        post("users") { req in
            // require that the request body be json
            guard let json = req.json else {
                throw Abort(.badRequest)
            }
            
            // initialize the name and email from
            // the request json
            let user = try User(json: json)
            
            // ensure no user with this email already exists
            guard try User.makeQuery().filter("email", user.email).first() == nil else {
                throw Abort(.badRequest, reason: "A user with that email already exists.")
            }
            
            // require a plaintext password is supplied
            guard let password = json["password"]?.string else {
                throw Abort(.badRequest)
            }
            
            // hash the password and set it on the user
            user.password = try self.hash.make(password.makeBytes()).makeString()
            
            // save and return the new user
            try user.save()
            
            // generate token for user 
            let token = try Token.generate(for: (try User.makeQuery().filter(User.Keys.email, user.email).first())!)
            
            // save user token
            try token.save()
            
            var resJSON = JSON()
            try resJSON.set("user", try user.makeJSON()) 
            try resJSON.set("token", token.token)
            
            return resJSON
        }
        
        
        // login a exist user
        //
        // POST /login
        // <json containing email and password information>
        post("login") {req in 
            // require that the request body be json
            guard let data = req.json else {
                throw Abort(.badRequest)
            }
            
            if let user = try User.makeQuery().filter(User.Keys.email, data[User.Keys.email]).first() {
                let inputPass = data[User.Keys.password]?.string
                if (try self.hash.check(inputPass!, matchesHash: user.password)) {
                    let token = try Token.generate(for: (try User.makeQuery().filter(User.Keys.email, user.email).first())!)
                    try token.save()
                    var resJSON = JSON()
                    try resJSON.set("user", try user.makeJSON()) 
                    try resJSON.set("token", token.token)
                    
                    return try! Response(status: .ok, json: resJSON)
                } else {
                    return try! Response(status: .badRequest, json: ["Message": "Bad Password"]) 
                }
            }
            return try! Response(status: .badRequest, json: ["Message": "User not exist"]) 
        }
    }
    
//    /// Sets up all routes that can be accessed using
//    /// username + password authentication.
//    /// Since we want to minimize how often the username + password
//    /// is sent, we will only use this form of authentication to
//    /// log the user in.
//    /// After the user is logged in, they will receive a token that
//    /// they can use for further authentication.
//    private func setupPasswordProtectedRoutes() throws {
//        // creates a route group protected by the password middleware.
//        // the User type can be passed to this middleware since it
//        // conforms to PasswordAuthenticatable
//        let password = grouped([
//            PasswordAuthenticationMiddleware(User.self)
//            ])
//        
//        // verifies the user has been authenticated using the password
//        // middleware, then generates, saves, and returns a new access token.
//        //
//        // POST /login
//        // Authorization: Basic <base64 email:password>
////        password.post("login") { req in
////            let user = try req.user()
////            let token = try Token.generate(for: user)
////            try token.save()
////            
////            let resJSON = ["user" : try user.makeJSON(),
////                           "token" : token.token] as [String : Any]
////            
////            return try JSON(node: resJSON)
////        }
//    }
    
    /// Sets up all routes that can be accessed using
    /// the authentication token received during login.
    /// All of our secure routes will go here.
    private func setupTokenProtectedRoutes() throws {
        // creates a route group protected by the token middleware.
        // the User type can be passed to this middleware since it
        // conforms to TokenAuthenticatable
        let token = grouped([
            TokenAuthenticationMiddleware(User.self)
            ])
        
        // simply returns a greeting to the user that has been authed
        // using the token middleware.
        //
        // PUT /logout
        // Authorization: Bearer <token from /login>
        token.post("logout") { (req) -> ResponseRepresentable in
            let inputToken = req.headers["Authorization"]
            if let token = try Token.makeQuery().filter("token", .equals , inputToken?.replacingOccurrences(of: "Bearer ", with: "")).first() {
                try token.delete()
                return try! Response(status: .ok, json: ["Message": "Succeful logout"]) 
            }
            return try! Response(status: .badRequest, json: ["Message": "Token not exist"]) 
        }
        
        
        // simply returns a greeting to the user that has been authed
        // using the token middleware.
        //
        // GET /me
        // Authorization: Bearer <token from /login>
        token.get("me") { req in
            let user = try req.user()
            
            return try user.makeJSON()
        }
        
        
//        // simply returns a greeting to the user that has been authed
//        // using the token middleware.
//        //
//        // GET | POST | PUT | DELETE /users
//        // Authorization: Bearer <token from /login>
//        try resource("users", UserController.self)
        
        // simply returns a greeting to the user that has been authed
        // using the token middleware.
        //
        // GET | POST | PUT | DELETE /posts
        // Authorization: Bearer <token from /login>
        token.get("posts") { req in 
            return try Post.makeQuery().all().makeJSON()
        }
        
        token.get("me/posts") { req in 
            let user = try req.user()
            return try Post.makeQuery().filter(Post.Keys.ownerId, .equals , user.id?.string).all().makeJSON()
        }
        
        token.get("posts", ":id") { req in 
            let postId = "oid:"+(req.parameters["id"]?.string)!
            return try Post.makeQuery().filter("_id", .equals , postId).first()!.makeJSON()
        }
        
        token.post("posts") { req in 
            try PostController().store(req)
        }
        
        token.delete("posts", ":id") { req in
            let postId = "oid:"+(req.parameters["id"]?.string)!
            if let post = try Post.makeQuery().filter("_id", .equals , postId).first() {
                let user = try req.user()
                if post.ownerId == user.id?.string! {
                    return try PostController().delete(req, post: post)
                } else {
                    throw Abort(.badRequest, reason: "You do not own property.")
                }
            } else {
                throw Abort(.badRequest, reason: "A post with that id not exists.")
            }
        }
        
        
        
//        try token.resource("posts", PostController.self)
//        try resource("posts", PostController.self)
    }
}
