
import Foundation
import KeychainSwift


protocol KeychainServiceProtocol {
    
    func set(_ value: String, forKey: String) -> Bool
    func get(_ forKey: String) -> String?
    func delete(_ forKey: String)
}


class KeychainService: KeychainServiceProtocol {
    
    let keychain = KeychainSwift()

    func set(_ value: String, forKey: String) -> Bool {
        keychain.set(value, forKey: forKey)
    }
    
    
    func get(_ forKey: String) -> String? {
        keychain.get(forKey)
    }
    
    func delete(_ forKey: String) {
        keychain.delete(forKey)
    }
    
}
