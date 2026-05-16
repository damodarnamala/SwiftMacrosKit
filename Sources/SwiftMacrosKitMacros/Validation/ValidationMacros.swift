// ValidationMacros.swift
// SwiftMacrosKit — Validation Macros
// Author: SwiftMacrosKit Contributors

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

// MARK: - Shared helper for peer macro backing storage

private func makePeerStorage(for declaration: some DeclSyntaxProtocol) -> [DeclSyntax] {
    guard let varDecl = declaration.as(VariableDeclSyntax.self),
          let name = varDecl.propertyName,
          let type = varDecl.propertyTypeName else {
        return []
    }
    if let initialValue = varDecl.initialValue {
        return ["var _\(raw: name): \(raw: type) = \(initialValue)"]
    }
    return ["var _\(raw: name): \(raw: type)"]
}

// MARK: - ValidatedMacro

/// Validates a property using a predicate closure via get/set accessors.
/// Usage: `@Validated({ $0 > 0 }) var count: Int = 1`
public struct ValidatedMacro: AccessorMacro, PeerMacro {
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

        let getter: AccessorDeclSyntax = "get { _\(raw: name) }"
        let setter: AccessorDeclSyntax = """
        set {
            let validate = \(predicateExpr)
            if validate(newValue) {
                _\(raw: name) = newValue
            }
        }
        """
        return [getter, setter]
    }

    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        makePeerStorage(for: declaration)
    }
}

// MARK: - NonEmptyMacro

/// Guards against empty `String` or `Array` assignments.
/// Usage: `@NonEmpty var name: String = "default"`
public struct NonEmptyMacro: AccessorMacro, PeerMacro {
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

        let getter: AccessorDeclSyntax = "get { _\(raw: name) }"
        let setter: AccessorDeclSyntax = """
        set {
            if !newValue.isEmpty {
                _\(raw: name) = newValue
            }
        }
        """
        return [getter, setter]
    }

    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        makePeerStorage(for: declaration)
    }
}

// MARK: - ClampedMacro

/// Clamps a numeric property value to a `min...max` range.
/// Usage: `@Clamped(min: 0, max: 100) var percentage: Int = 50`
public struct ClampedMacro: AccessorMacro, PeerMacro {
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

        let getter: AccessorDeclSyntax = "get { _\(raw: name) }"
        let setter: AccessorDeclSyntax = """
        set {
            if newValue < \(minExpr) {
                _\(raw: name) = \(minExpr)
            } else if newValue > \(maxExpr) {
                _\(raw: name) = \(maxExpr)
            } else {
                _\(raw: name) = newValue
            }
        }
        """
        return [getter, setter]
    }

    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        makePeerStorage(for: declaration)
    }
}

// MARK: - RegexValidatedMacro

/// Validates a `String` property against a regex pattern.
/// Usage: `@RegexValidated("^[0-9]+$") var code: String = "123"`
public struct RegexValidatedMacro: AccessorMacro, PeerMacro {
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

        let getter: AccessorDeclSyntax = "get { _\(raw: name) }"
        let setter: AccessorDeclSyntax = """
        set {
            let pattern = \(literal: pattern)
            if newValue.range(of: pattern, options: .regularExpression) != nil {
                _\(raw: name) = newValue
            }
        }
        """
        return [getter, setter]
    }

    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        makePeerStorage(for: declaration)
    }
}

// MARK: - EmailMacro

/// Validates that a `String` property contains a valid email format.
/// Usage: `@Email var email: String = "user@example.com"`
public struct EmailMacro: AccessorMacro, PeerMacro {
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

        let getter: AccessorDeclSyntax = "get { _\(raw: name) }"
        let setter: AccessorDeclSyntax = """
        set {
            let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\\\.[A-Za-z]{2,}"
            let pred = NSPredicate(format: "SELF MATCHES %@", pattern)
            if pred.evaluate(with: newValue) {
                _\(raw: name) = newValue
            }
        }
        """
        return [getter, setter]
    }

    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        makePeerStorage(for: declaration)
    }
}

// MARK: - URLValidatedMacro

/// Validates that a `String` property contains a valid URL.
/// Usage: `@URLValidated var link: String = "https://example.com"`
public struct URLValidatedMacro: AccessorMacro, PeerMacro {
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

        let getter: AccessorDeclSyntax = "get { _\(raw: name) }"
        let setter: AccessorDeclSyntax = """
        set {
            if URL(string: newValue) != nil {
                _\(raw: name) = newValue
            }
        }
        """
        return [getter, setter]
    }

    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        makePeerStorage(for: declaration)
    }
}

// MARK: - MinLengthMacro

/// Enforces a minimum count/length on a `String` or `Array` property.
/// Usage: `@MinLength(3) var username: String = "abc"`
public struct MinLengthMacro: AccessorMacro, PeerMacro {
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

        let getter: AccessorDeclSyntax = "get { _\(raw: name) }"
        let setter: AccessorDeclSyntax = """
        set {
            if newValue.count >= \(minExpr) {
                _\(raw: name) = newValue
            }
        }
        """
        return [getter, setter]
    }

    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        makePeerStorage(for: declaration)
    }
}

// MARK: - MaxLengthMacro

/// Enforces a maximum count/length on a `String` or `Array` property.
/// Usage: `@MaxLength(100) var bio: String = ""`
public struct MaxLengthMacro: AccessorMacro, PeerMacro {
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

        let getter: AccessorDeclSyntax = "get { _\(raw: name) }"
        let setter: AccessorDeclSyntax = """
        set {
            if newValue.count > \(maxExpr) {
                let endIndex = newValue.index(newValue.startIndex, offsetBy: \(maxExpr))
                _\(raw: name) = String(newValue[newValue.startIndex..<endIndex])
            } else {
                _\(raw: name) = newValue
            }
        }
        """
        return [getter, setter]
    }

    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        makePeerStorage(for: declaration)
    }
}

// MARK: - NotNilMacro

/// Traps with a meaningful message if the property is set to `nil`.
/// Usage: `@NotNil var value: String? = "hello"`
public struct NotNilMacro: AccessorMacro, PeerMacro {
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

        let getter: AccessorDeclSyntax = "get { _\(raw: name) }"
        let setter: AccessorDeclSyntax = """
        set {
            if newValue == nil {
                preconditionFailure("\\(type(of: self)).\(raw: name) must not be nil")
            }
            _\(raw: name) = newValue
        }
        """
        return [getter, setter]
    }

    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        makePeerStorage(for: declaration)
    }
}

// MARK: - RangeMacro

/// Asserts that a numeric property value is within a given range, trapping otherwise.
/// Usage: `@Range(min: 1, max: 10) var level: Int = 5`
public struct RangeMacro: AccessorMacro, PeerMacro {
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

        let getter: AccessorDeclSyntax = "get { _\(raw: name) }"
        let setter: AccessorDeclSyntax = """
        set {
            precondition(newValue >= \(lowerExpr) && newValue <= \(upperExpr),
                "\\(type(of: self)).\(raw: name) must be in range \\(\(lowerExpr))...\\(\(upperExpr)), got \\(newValue)")
            _\(raw: name) = newValue
        }
        """
        return [getter, setter]
    }

    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        makePeerStorage(for: declaration)
    }
}
