// ValidationMacros.swift
// SwiftMacrosKit — Validation Macros
// Author: SwiftMacrosKit Contributors

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

// MARK: - ValidatedMacro

/// Adds a `didSet` accessor that validates a property using a predicate closure.
/// Usage: `@Validated({ $0 > 0 }) var count: Int = 1`
public struct ValidatedMacro: AccessorMacro {
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
        guard let predicateExpr = args.first?.expression else {
            context.addDiagnostic(.missingArguments, at: node)
            return []
        }

        let accessor: AccessorDeclSyntax = """
        didSet {
            let validate = \(predicateExpr)
            if !validate(\(raw: name)) {
                \(raw: name) = oldValue
            }
        }
        """
        return [accessor]
    }
}

// MARK: - NonEmptyMacro

/// Guards against empty `String` or `Array` assignments by reverting to `oldValue`.
/// Usage: `@NonEmpty var name: String = "default"`
public struct NonEmptyMacro: AccessorMacro {
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

        let accessor: AccessorDeclSyntax = """
        didSet {
            if \(raw: name).isEmpty {
                \(raw: name) = oldValue
            }
        }
        """
        return [accessor]
    }
}

// MARK: - ClampedMacro

/// Clamps a numeric property value to a `min...max` range.
/// Usage: `@Clamped(min: 0, max: 100) var percentage: Int = 50`
public struct ClampedMacro: AccessorMacro {
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
        guard args.count >= 2,
              let minExpr = args.first(where: { $0.label == "min" })?.expression,
              let maxExpr = args.first(where: { $0.label == "max" })?.expression else {
            context.addDiagnostic(.missingArguments, at: node)
            return []
        }

        let accessor: AccessorDeclSyntax = """
        didSet {
            if \(raw: name) < \(minExpr) { \(raw: name) = \(minExpr) }
            if \(raw: name) > \(maxExpr) { \(raw: name) = \(maxExpr) }
        }
        """
        return [accessor]
    }
}

// MARK: - RegexValidatedMacro

/// Validates a `String` property against a regex pattern, reverting on mismatch.
/// Usage: `@RegexValidated("^[0-9]+$") var code: String = "123"`
public struct RegexValidatedMacro: AccessorMacro {
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

        let args = node.stringArguments
        guard let pattern = args.first else {
            context.addDiagnostic(.missingArguments, at: node)
            return []
        }

        let accessor: AccessorDeclSyntax = """
        didSet {
            let pattern = \(literal: pattern)
            if \(raw: name).range(of: pattern, options: .regularExpression) == nil {
                \(raw: name) = oldValue
            }
        }
        """
        return [accessor]
    }
}

// MARK: - EmailMacro

/// Validates that a `String` property contains a valid email format.
/// Usage: `@Email var email: String = "user@example.com"`
public struct EmailMacro: AccessorMacro {
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

        let accessor: AccessorDeclSyntax = """
        didSet {
            let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\\\.[A-Za-z]{2,}"
            let pred = NSPredicate(format: "SELF MATCHES %@", pattern)
            if !pred.evaluate(with: \(raw: name)) {
                \(raw: name) = oldValue
            }
        }
        """
        return [accessor]
    }
}

// MARK: - URLValidatedMacro

/// Validates that a `String` property contains a valid URL.
/// Usage: `@URLValidated var link: String = "https://example.com"`
public struct URLValidatedMacro: AccessorMacro {
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

        let accessor: AccessorDeclSyntax = """
        didSet {
            if URL(string: \(raw: name)) == nil {
                \(raw: name) = oldValue
            }
        }
        """
        return [accessor]
    }
}

// MARK: - MinLengthMacro

/// Enforces a minimum count/length on a `String` or `Array` property.
/// Usage: `@MinLength(3) var username: String = "abc"`
public struct MinLengthMacro: AccessorMacro {
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
        guard let minExpr = args.first?.expression else {
            context.addDiagnostic(.missingArguments, at: node)
            return []
        }

        let accessor: AccessorDeclSyntax = """
        didSet {
            if \(raw: name).count < \(minExpr) {
                \(raw: name) = oldValue
            }
        }
        """
        return [accessor]
    }
}

// MARK: - MaxLengthMacro

/// Enforces a maximum count/length on a `String` or `Array` property.
/// Usage: `@MaxLength(100) var bio: String = ""`
public struct MaxLengthMacro: AccessorMacro {
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
        guard let maxExpr = args.first?.expression else {
            context.addDiagnostic(.missingArguments, at: node)
            return []
        }

        let accessor: AccessorDeclSyntax = """
        didSet {
            if \(raw: name).count > \(maxExpr) {
                let endIndex = \(raw: name).index(\(raw: name).startIndex, offsetBy: \(maxExpr))
                \(raw: name) = String(\(raw: name)[\(raw: name).startIndex..<endIndex])
            }
        }
        """
        return [accessor]
    }
}

// MARK: - NotNilMacro

/// Generates a `didSet` that traps with a meaningful message if assigned `nil`.
/// Usage: `@NotNil var value: String? = "hello"`
public struct NotNilMacro: AccessorMacro {
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

        let accessor: AccessorDeclSyntax = """
        didSet {
            if \(raw: name) == nil {
                preconditionFailure("\\(type(of: self)).\(raw: name) must not be nil")
            }
        }
        """
        return [accessor]
    }
}

// MARK: - RangeMacro

/// Asserts that a numeric property value is within a given range, trapping otherwise.
/// Usage: `@Range(1, 10) var level: Int = 5`
public struct RangeMacro: AccessorMacro {
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
        guard args.count >= 2 else {
            context.addDiagnostic(.missingArguments, at: node)
            return []
        }

        let lowerExpr = args[0].expression
        let upperExpr = args[1].expression

        let accessor: AccessorDeclSyntax = """
        didSet {
            precondition(\(raw: name) >= \(lowerExpr) && \(raw: name) <= \(upperExpr),
                "\\(type(of: self)).\(raw: name) must be in range \\(\(lowerExpr))...\\(\(upperExpr)), got \\(\(raw: name))")
        }
        """
        return [accessor]
    }
}
