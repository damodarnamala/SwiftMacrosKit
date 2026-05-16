// SecurityMacroDeclarations.swift
// SwiftMacrosKit — Security Macro Declarations
// Category: [H] Security
// Author: SwiftMacrosKit Contributors

/// Encrypts on set, decrypts on get using CryptoKit.
///
/// - Parameter algorithm: The encryption algorithm (default: .aes).
///
/// **Usage:** `@Encrypted(algorithm: .aes) var secret: String`
@attached(accessor)
@attached(peer, names: prefixed(_))
public macro Encrypted(algorithm: String = ".aes") = #externalMacro(module: "SwiftMacrosKitMacros", type: "EncryptedMacro")

/// One-way hash on assignment using SHA256/SHA512.
///
/// - Parameter using: The hash algorithm (default: .sha256).
///
/// **Usage:** `@Hashed(using: .sha256) var password: String`
@attached(accessor)
@attached(peer, names: prefixed(_))
public macro Hashed(using: String = ".sha256") = #externalMacro(module: "SwiftMacrosKitMacros", type: "HashedMacro")

/// Replaces value with "***" in CustomStringConvertible output and logs.
///
/// **Usage:** `@Redacted var ssn: String`
@attached(accessor)
@attached(peer, names: prefixed(_))
public macro Redacted() = #externalMacro(module: "SwiftMacrosKitMacros", type: "RedactedMacro")

/// Strips HTML/script tags and trims whitespace on assignment.
///
/// **Usage:** `@Sanitized var userInput: String`
@attached(accessor)
@attached(peer, names: prefixed(_))
public macro Sanitized() = #externalMacro(module: "SwiftMacrosKitMacros", type: "SanitizedMacro")

/// Wraps function execution behind LAContext biometric evaluation.
///
/// **Usage:** `@BiometricGated func showSecretData() { ... }`
@attached(peer, names: prefixed(`biometricGated_`))
public macro BiometricGated() = #externalMacro(module: "SwiftMacrosKitMacros", type: "BiometricGatedMacro")

/// Stores/retrieves data using SecureEnclave key pair via CryptoKit.
///
/// **Usage:** `@SecureEnclave var sensitiveData: Data`
@attached(accessor)
@attached(peer, names: prefixed(_))
public macro SecureEnclave() = #externalMacro(module: "SwiftMacrosKitMacros", type: "SecureEnclaveMacro")
