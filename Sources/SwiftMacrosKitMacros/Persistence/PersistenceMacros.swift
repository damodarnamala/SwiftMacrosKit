// PersistenceMacros.swift
// SwiftMacrosKit — Persistence & Storage Macro Implementations
// Category: [D] Persistence & Storage
// Author: SwiftMacrosKit Contributors

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

// MARK: - UserDefaultMacro

public struct UserDefaultMacro: AccessorMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        guard let varDecl = declaration.as(VariableDeclSyntax.self),
              let name = varDecl.propertyName,
              let type = varDecl.propertyTypeName else {
            context.addDiagnostic(.requiresProperty, at: node)
            return []
        }

        let args = node.labeledArguments
        guard let keyExpr = args.first(where: { $0.label == "key" })?.expression else {
            context.addDiagnostic(.missingKey, at: node)
            return []
        }

        let defaultExpr = args.first(where: { $0.label == "default" })?.expression

        let getter: AccessorDeclSyntax
        if let defaultExpr = defaultExpr {
            getter = """
            get {
                UserDefaults.standard.object(forKey: \(keyExpr)) as? \(raw: type) ?? \(defaultExpr)
            }
            """
        } else {
            getter = """
            get {
                UserDefaults.standard.object(forKey: \(keyExpr)) as? \(raw: type)
            }
            """
        }

        let setter: AccessorDeclSyntax = """
        set {
            UserDefaults.standard.set(newValue, forKey: \(keyExpr))
        }
        """

        return [getter, setter]
    }
}

// MARK: - KeychainMacro

public struct KeychainMacro: AccessorMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        guard let varDecl = declaration.as(VariableDeclSyntax.self),
              let name = varDecl.propertyName else {
            context.addDiagnostic(.requiresProperty, at: node)
            return []
        }

        let args = node.labeledArguments
        let service = args.first(where: { $0.label == "service" })?.expression.trimmedDescription ?? "\"default\""
        let account = args.first(where: { $0.label == "account" })?.expression.trimmedDescription ?? "\"\(name)\""

        let getter: AccessorDeclSyntax = """
        get {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: \(raw: service),
                kSecAttrAccount as String: \(raw: account),
                kSecReturnData as String: true,
                kSecMatchLimit as String: kSecMatchLimitOne
            ]
            var result: AnyObject?
            SecItemCopyMatching(query as CFDictionary, &result)
            return (result as? Data).flatMap { String(data: $0, encoding: .utf8) }
        }
        """

        let setter: AccessorDeclSyntax = """
        set {
            let data = newValue?.data(using: .utf8)
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: \(raw: service),
                kSecAttrAccount as String: \(raw: account)
            ]
            SecItemDelete(query as CFDictionary)
            if let data = data {
                var attrs = query
                attrs[kSecValueData as String] = data
                SecItemAdd(attrs as CFDictionary, nil)
            }
        }
        """

        return [getter, setter]
    }
}

// MARK: - CloudSyncMacro

public struct CloudSyncMacro: AccessorMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        guard let varDecl = declaration.as(VariableDeclSyntax.self),
              let type = varDecl.propertyTypeName else {
            context.addDiagnostic(.requiresProperty, at: node)
            return []
        }

        let keyExpr = node.labeledArguments.first(where: { $0.label == "key" })?.expression
            ?? node.labeledArguments.first?.expression

        guard let keyExpr = keyExpr else {
            context.addDiagnostic(.missingKey, at: node)
            return []
        }

        let getter: AccessorDeclSyntax = """
        get {
            NSUbiquitousKeyValueStore.default.object(forKey: \(keyExpr)) as? \(raw: type)
        }
        """

        let setter: AccessorDeclSyntax = """
        set {
            NSUbiquitousKeyValueStore.default.set(newValue, forKey: \(keyExpr))
            NSUbiquitousKeyValueStore.default.synchronize()
        }
        """

        return [getter, setter]
    }
}

// MARK: - FileStoredMacro

public struct FileStoredMacro: AccessorMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        guard let varDecl = declaration.as(VariableDeclSyntax.self),
              let type = varDecl.propertyTypeName else {
            context.addDiagnostic(.requiresProperty, at: node)
            return []
        }

        let pathExpr = node.labeledArguments.first(where: { $0.label == "path" })?.expression
            ?? node.labeledArguments.first?.expression

        guard let pathExpr = pathExpr else {
            context.addDiagnostic(.missingPath, at: node)
            return []
        }

        let getter: AccessorDeclSyntax = """
        get {
            guard let data = try? Data(contentsOf: URL(fileURLWithPath: \(pathExpr))) else { return nil }
            return try? JSONDecoder().decode(\(raw: type).self, from: data)
        }
        """

        let setter: AccessorDeclSyntax = """
        set {
            guard let data = try? JSONEncoder().encode(newValue) else { return }
            try? data.write(to: URL(fileURLWithPath: \(pathExpr)))
        }
        """

        return [getter, setter]
    }
}

// MARK: - CoreDataEntityMacro

public struct CoreDataEntityMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let classDecl = declaration.as(ClassDeclSyntax.self) else {
            context.addDiagnostic(.requiresClass, at: node)
            return []
        }

        let properties = declaration.storedProperties
        var managedProps = [DeclSyntax]()

        for prop in properties {
            guard let name = prop.propertyName,
                  let type = prop.propertyTypeName else { continue }
            managedProps.append("@NSManaged var \(raw: name): \(raw: type)")
        }

        return managedProps
    }
}

// MARK: - SwiftDataModelMacro

public struct SwiftDataModelMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard declaration.isClass else {
            context.addDiagnostic(.requiresClass, at: node)
            return []
        }

        guard let typeName = declaration.typeName else { return [] }
        let properties = declaration.storedProperties

        var params = [String]()
        var assigns = [String]()
        for prop in properties {
            guard let name = prop.propertyName,
                  let type = prop.propertyTypeName else { continue }
            if prop.isOptional {
                params.append("\(name): \(type) = nil")
            } else if let defaultVal = prop.initialValue {
                params.append("\(name): \(type) = \(defaultVal.trimmedDescription)")
            } else {
                params.append("\(name): \(type)")
            }
            assigns.append("self.\(name) = \(name)")
        }

        let paramsStr = params.joined(separator: ", ")
        let assignsStr = assigns.joined(separator: "\n        ")

        return ["""
        init(\(raw: paramsStr)) {
            \(raw: assignsStr)
        }
        """]
    }
}

// MARK: - CachedMacro

public struct CachedMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let funcDecl = declaration.as(FunctionDeclSyntax.self) else {
            // Also support property attachment
            if let varDecl = declaration.as(VariableDeclSyntax.self),
               let name = varDecl.propertyName,
               let type = varDecl.propertyTypeName {
                let ttl = node.labeledArguments.first(where: { $0.label == "ttl" })?.expression.trimmedDescription ?? "300"
                return [
                    "private var _cache_\(raw: name): (value: \(raw: type), date: Date)?",
                    """
                    private func _getCached_\(raw: name)() -> \(raw: type)? {
                        guard let cached = _cache_\(raw: name),
                              Date().timeIntervalSince(cached.date) < \(raw: ttl) else {
                            return nil
                        }
                        return cached.value
                    }
                    """,
                ]
            }
            context.addDiagnostic(.requiresFunction, at: node)
            return []
        }

        let name = funcDecl.functionName
        let returnType = funcDecl.returnTypeName ?? "Void"
        let ttl = node.labeledArguments.first(where: { $0.label == "ttl" })?.expression.trimmedDescription ?? "300"

        return [
            "private var _cache_\(raw: name): (value: \(raw: returnType), date: Date)?",
            """
            func cached_\(raw: name)() -> \(raw: returnType)? {
                guard let cached = _cache_\(raw: name),
                      Date().timeIntervalSince(cached.date) < \(raw: ttl) else {
                    return nil
                }
                return cached.value
            }
            """,
        ]
    }
}

// MARK: - PersistedMacro

public struct PersistedMacro: AccessorMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        guard let varDecl = declaration.as(VariableDeclSyntax.self),
              let name = varDecl.propertyName,
              let type = varDecl.propertyTypeName else {
            context.addDiagnostic(.requiresProperty, at: node)
            return []
        }

        let key = "\(name)"

        let getter: AccessorDeclSyntax = """
        get {
            guard let data = UserDefaults.standard.data(forKey: \(literal: key)) else { return nil }
            return try? JSONDecoder().decode(\(raw: type).self, from: data)
        }
        """

        let setter: AccessorDeclSyntax = """
        set {
            let data = try? JSONEncoder().encode(newValue)
            UserDefaults.standard.set(data, forKey: \(literal: key))
        }
        """

        return [getter, setter]
    }
}
