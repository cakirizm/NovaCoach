import Foundation
import Security
import CryptoKit

final class CredentialStore {
    static let shared = CredentialStore()
    private let service = "com.novacoach.app.auth"
    private let accountKey = "accounts"
    private init() {}

    func register(name: String, email: String, password: String) throws -> AuthAccount {
        let normalized = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard normalized.contains("@"), password.count >= 6, name.trimmingCharacters(in: .whitespaces).count >= 2 else { throw AuthError.invalidInput }
        var accounts = loadAccounts()
        guard !accounts.contains(where: { $0.email == normalized }) else { throw AuthError.accountExists }
        let salt = UUID().uuidString
        let account = AuthAccount(email: normalized, displayName: name.trimmingCharacters(in: .whitespaces), salt: salt, passwordHash: hash(password: password, salt: salt), createdAt: Date())
        accounts.append(account)
        try saveAccounts(accounts)
        return account
    }

    func login(email: String, password: String) throws -> AuthAccount {
        let normalized = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard let account = loadAccounts().first(where: { $0.email == normalized }) else { throw AuthError.invalidCredentials }
        guard hash(password: password, salt: account.salt) == account.passwordHash else { throw AuthError.invalidCredentials }
        return account
    }

    func resetPassword(email: String, newPassword: String) throws {
        let normalized = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard newPassword.count >= 6 else { throw AuthError.invalidInput }
        var accounts = loadAccounts()
        guard let index = accounts.firstIndex(where: { $0.email == normalized }) else { throw AuthError.notFound }
        let old = accounts[index]
        let salt = UUID().uuidString
        accounts[index] = AuthAccount(email: old.email, displayName: old.displayName, salt: salt, passwordHash: hash(password: newPassword, salt: salt), createdAt: old.createdAt)
        try saveAccounts(accounts)
    }

    private func hash(password: String, salt: String) -> String {
        let digest = SHA256.hash(data: Data((salt + password).utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    private func loadAccounts() -> [AuthAccount] {
        guard let data = readKeychain(), let accounts = try? JSONDecoder().decode([AuthAccount].self, from: data) else { return [] }
        return accounts
    }

    private func saveAccounts(_ accounts: [AuthAccount]) throws {
        let data = try JSONEncoder().encode(accounts)
        let base: [String: Any] = [kSecClass as String: kSecClassGenericPassword, kSecAttrService as String: service, kSecAttrAccount as String: accountKey]
        SecItemDelete(base as CFDictionary)
        var insert = base
        insert[kSecValueData as String] = data
        let status = SecItemAdd(insert as CFDictionary, nil)
        guard status == errSecSuccess else { throw AuthError.storageFailure }
    }

    private func readKeychain() -> Data? {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword, kSecAttrService as String: service, kSecAttrAccount as String: accountKey, kSecReturnData as String: true, kSecMatchLimit as String: kSecMatchLimitOne]
        var result: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess else { return nil }
        return result as? Data
    }
}

enum AuthError: LocalizedError {
    case invalidInput, accountExists, invalidCredentials, notFound, storageFailure
    var errorDescription: String? {
        switch self {
        case .invalidInput: return "Ad, geçerli e-posta ve en az 6 karakterli şifre gerekli."
        case .accountExists: return "Bu e-posta ile daha önce hesap oluşturulmuş."
        case .invalidCredentials: return "E-posta veya şifre hatalı."
        case .notFound: return "Bu e-posta ile kayıtlı hesap bulunamadı."
        case .storageFailure: return "Hesap güvenli şekilde kaydedilemedi."
        }
    }
}
