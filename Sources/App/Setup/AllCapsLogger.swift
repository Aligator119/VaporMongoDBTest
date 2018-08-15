//
//  AllCapsLogger.swift
//  App
//
//  Created by Ivan Irchak on 6/27/18.
//

import Foundation

final class AllCapsLogger: LogProtocol {
    var enabled: [LogLevel] = []
    let exclamationCount: Int
    
    init(exclamationCount: Int) {
        self.exclamationCount = exclamationCount
    }
    
    func log(_ level: LogLevel, message: String, file: String, function: String, line: Int) {
        print(message.uppercased() + String(repeating: "!", count: exclamationCount))
    }
}

extension AllCapsLogger: ConfigInitializable {
    convenience init(config: Config) throws {
        let count = config["allCaps", "exclamationCount"]?.int ?? 3
        self.init(exclamationCount: count)
    } 
}
