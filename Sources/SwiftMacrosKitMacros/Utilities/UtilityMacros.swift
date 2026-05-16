// UtilityMacros.swift
// SwiftMacrosKit — Utility & DX Macro Implementations
// Category: [K] Utilities & DX
// Author: SwiftMacrosKit Contributors

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

// MARK: - EquatablePlusMacro

public struct EquatablePlusMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard declaration.isClass, let typeName = declaration.typeName else {
            context.addDiagnostic(.requiresClass, at: node)
            return []
        }

        let properties = declaration.storedProperties
        var comparisons = [String]()
        for prop in properties {
            guard let name = prop.propertyName else { continue }
            comparisons.append("lhs.\(name) == rhs.\(name)")
        }

        let compStr = comparisons.joined(separator: " && ")

        return ["""
        static func == (lhs: \(raw: typeName), rhs: \(raw: typeName)) -> Bool {
            \(raw: compStr.isEmpty ? "true" : compStr)
        }
        """]
    }
}

// MARK: - ComparablePlusMacro

public struct ComparablePlusMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let typeName = declaration.typeName else { return [] }

        let keyPath = node.stringArguments.first ?? node.labeledArguments.first?.expression.trimmedDescription

        guard let keyPath = keyPath else {
            // Use first property
            let firstProp = declaration.storedProperties.first?.propertyName ?? "self"
            return ["""
            static func < (lhs: \(raw: typeName), rhs: \(raw: typeName)) -> Bool {
                lhs.\(raw: firstProp) < rhs.\(raw: firstProp)
            }
            """]
        }

        return ["""
        static func < (lhs: \(raw: typeName), rhs: \(raw: typeName)) -> Bool {
            lhs[keyPath: \(raw: keyPath)] < rhs[keyPath: \(raw: keyPath)]
        }
        """]
    }
}

// MARK: - CopyableMacro

public struct CopyableMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard declaration.isStruct, let typeName = declaration.typeName else {
            context.addDiagnostic(.requiresStruct, at: node)
            return []
        }

        return ["""
        func copy(_ modifier: (inout \(raw: typeName)) -> Void) -> \(raw: typeName) {
            var copy = self
            modifier(&copy)
            return copy
        }
        """]
    }
}

// MARK: - StringConvertibleMacro

public struct StringConvertibleMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let typeName = declaration.typeName else { return [] }

        let properties = declaration.storedProperties
        var parts = [String]()
        for prop in properties {
            guard let name = prop.propertyName else { continue }
            parts.append("\(name): \\(\(name))")
        }

        let propsStr = parts.joined(separator: ", ")

        return ["""
        var description: String {
            "\(raw: typeName)(\(raw: propsStr))"
        }
        """]
    }
}

// MARK: - CaseIterablePlusMacro

public struct CaseIterablePlusMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let enumDecl = declaration.as(EnumDeclSyntax.self) else {
            context.addDiagnostic(.requiresEnum, at: node)
            return []
        }

        let typeName = enumDecl.name.trimmedDescription
        let cases = enumDecl.caseElements

        var caseList = [String]()
        for caseElem in cases {
            let name = caseElem.name.trimmedDescription
            if let paramClause = caseElem.parameterClause {
                var defaults = [String]()
                for param in paramClause.parameters {
                    let type = param.type.trimmedDescription
                    let label = param.firstName?.trimmedDescription ?? "_"
                    let defaultVal: String
                    switch type {
                    case "String": defaultVal = "\"\""
                    case "Int", "Int8", "Int16", "Int32", "Int64": defaultVal = "0"
                    case "Double", "Float", "CGFloat": defaultVal = "0.0"
                    case "Bool": defaultVal = "false"
                    default: defaultVal = ".init()"
                    }
                    defaults.append("\(label): \(defaultVal)")
                }
                caseList.append(".\(name)(\(defaults.joined(separator: ", ")))")
            } else {
                caseList.append(".\(name)")
            }
        }

        let casesStr = caseList.joined(separator: ", ")

        return ["""
        static var allCases: [\(raw: typeName)] {
            [\(raw: casesStr)]
        }
        """]
    }
}

// MARK: - DefaultableMacro

public struct DefaultableMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let protocolDecl = declaration.as(ProtocolDeclSyntax.self) else {
            context.addDiagnostic(.requiresProtocol, at: node)
            return []
        }

        let protocolName = protocolDecl.name.trimmedDescription

        var defaultProps = [String]()
        for prop in protocolDecl.propertyRequirements {
            guard let name = prop.propertyName,
                  let type = prop.propertyTypeName else { continue }
            let defaultVal: String
            switch type {
            case "String": defaultVal = "\"\""
            case "Int": defaultVal = "0"
            case "Double", "Float": defaultVal = "0.0"
            case "Bool": defaultVal = "false"
            default: defaultVal = ".init()"
            }
            defaultProps.append("var \(name): \(type) { \(defaultVal) }")
        }

        let propsStr = defaultProps.joined(separator: "\n    ")

        return ["""
        extension \(raw: protocolName) {
            \(raw: propsStr)
        }
        """]
    }
}

// MARK: - DecodablePlusMacro

public struct DecodablePlusMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard declaration.isStruct, let typeName = declaration.typeName else {
            context.addDiagnostic(.requiresStruct, at: node)
            return []
        }

        let properties = declaration.storedProperties

        var codingKeys = [String]()
        var decodings = [String]()

        for prop in properties {
            guard let name = prop.propertyName,
                  let type = prop.propertyTypeName else { continue }

            codingKeys.append("case \(name)")

            if let defaultVal = prop.initialValue {
                decodings.append("\(name) = (try? container.decode(\(type).self, forKey: .\(name))) ?? \(defaultVal.trimmedDescription)")
            } else if prop.isOptional {
                decodings.append("\(name) = try? container.decode(\(type).self, forKey: .\(name))")
            } else {
                decodings.append("\(name) = try container.decode(\(type).self, forKey: .\(name))")
            }
        }

        let keysStr = codingKeys.joined(separator: "\n        ")
        let decodingsStr = decodings.joined(separator: "\n        ")

        return [
            """
            enum CodingKeys: String, CodingKey {
                \(raw: keysStr)
            }
            """,
            """
            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                \(raw: decodingsStr)
            }
            """,
        ]
    }
}

// MARK: - EncodablePlusMacro

public struct EncodablePlusMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard declaration.isStruct, let typeName = declaration.typeName else {
            context.addDiagnostic(.requiresStruct, at: node)
            return []
        }

        let properties = declaration.storedProperties
        var encodings = [String]()

        for prop in properties {
            guard let name = prop.propertyName else { continue }
            // Skip properties marked with @EncodingIgnored
            let isIgnored = prop.attributes.contains { attr in
                attr.as(AttributeSyntax.self)?.attributeName.trimmedDescription == "EncodingIgnored"
            }
            if !isIgnored {
                encodings.append("try container.encode(\(name), forKey: .\(name))")
            }
        }

        let encodingsStr = encodings.joined(separator: "\n        ")

        return ["""
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            \(raw: encodingsStr)
        }
        """]
    }
}

// MARK: - FlaggedMacro

public struct FlaggedMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let funcDecl = declaration.as(FunctionDeclSyntax.self) else {
            context.addDiagnostic(.requiresFunction, at: node)
            return []
        }

        let name = funcDecl.functionName
        let args = node.labeledArguments
        let key = args.first(where: { $0.label == "key" })?.expression.trimmedDescription
            ?? node.stringArguments.first ?? "\"\(name)\""
        let defaultVal = args.first(where: { $0.label == "default" })?.expression.trimmedDescription ?? "false"

        return ["""
        func flagged_\(raw: name)() {
            let isEnabled = UserDefaults.standard.bool(forKey: \(raw: key))
            guard isEnabled else { return }
            \(raw: name)()
        }
        """]
    }
}

// MARK: - DeprecatedPlusMacro

public struct DeprecatedPlusMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // This macro is primarily documentation-oriented
        // It adds a deprecation wrapper that logs usage
        guard let funcDecl = declaration.as(FunctionDeclSyntax.self) else {
            return []
        }

        let name = funcDecl.functionName
        let args = node.labeledArguments
        let message = args.first(where: { $0.label == "message" })?.expression.trimmedDescription
            ?? node.stringArguments.first ?? "\"This API is deprecated\""
        let replacement = args.first(where: { $0.label == "replacement" })?.expression.trimmedDescription ?? "nil"

        return ["""
        @available(*, deprecated, message: \(raw: message))
        func deprecated_\(raw: name)() {
            print("WARNING: \(raw: name) is deprecated. \\(\(raw: replacement) ?? "")")
            \(raw: name)()
        }
        """]
    }
}
