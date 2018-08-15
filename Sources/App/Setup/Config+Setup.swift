import FluentProvider
import MongoProvider
import LeafProvider
import AuthProvider
 

extension Config {
    public func setup() throws {
        // allow fuzzy conversions for these types
        // (add your own types here)

        try setupProviders()
        try setupPreparations()
    }
    
    /// Configure providers
    private func setupProviders() throws {
        try addProvider(FluentProvider.Provider.self)
        try addProvider(LeafProvider.Provider.self)
        try addProvider(MongoProvider.Provider.self)
        try addProvider(AuthProvider.Provider.self)
    }
    
    /// Add all models that should have their
    /// schemas prepared before the app boots
    private func setupPreparations() throws {
        preparations.append(User.self)
        preparations.append(Token.self)
        preparations.append(Post.self)
    }
}
