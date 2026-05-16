// SyntaxHelpers.swift
// SwiftMacrosKit — Shared Syntax Utilities
// Author: SwiftMacrosKit Contributors

import SwiftSyntax

// MARK: - Variable Declaration Helpers

public extension VariableDeclSyntax {
    /// Returns the name of the first binding's pattern.
    var propertyName: String? {
        bindings.first?.pattern.trimmedDescription
    }

    /// Returns the type annotation string of the first binding.
    var propertyTypeName: String? {
        bindings.first?.typeAnnotation?.type.trimmedDescription
    }

    /// Whether this is a stored property (has no accessor block or has only willSet/didSet).
    var isStoredProperty: Bool {
        guard let binding = bindings.first else { return false }
        guard let accessor = binding.accessorBlock else { return true }
        switch accessor.accessors {
        case .accessors(let list):
            let accessorKinds = list.map { $0.accessorSpecifier.tokenKind }
            let isObserverOnly = accessorKinds.allSatisfy {
                $0 == .keyword(.willSet) || $0 == .keyword(.didSet)
            }
            return isObserverOnly
        case .getter:
            return false
        }
    }

    /// Whether this property is computed (get-only or get/set with bodies).
    var isComputedProperty: Bool {
        !isStoredProperty
    }

    /// Whether this property is declared as optional (T?).
    var isOptional: Bool {
        guard let typeName = propertyTypeName else { return false }
        return typeName.hasSuffix("?") || typeName.hasPrefix("Optional<")
    }

    /// Whether this property is a let constant.
    var isLet: Bool {
        bindingSpecifier.tokenKind == .keyword(.let)
    }

    /// Whether this property is a var.
    var isVar: Bool {
        bindingSpecifier.tokenKind == .keyword(.var)
    }

    /// Returns the initial value expression if present.
    var initialValue: ExprSyntax? {
        bindings.first?.initializer?.value
    }
}

// MARK: - Function Declaration Helpers

public extension FunctionDeclSyntax {
    /// Returns the function name as a string.
    var functionName: String {
        name.trimmedDescription
    }

    /// Whether this function is async.
    var isAsync: Bool {
        signature.effectSpecifiers?.asyncSpecifier != nil
    }

    /// Whether this function throws.
    var isThrowing: Bool {
        signature.effectSpecifiers?.throwsSpecifier != nil
    }

    /// Returns parameter names and types as tuples.
    var parameters: [(firstName: String?, secondName: String?, type: String)] {
        signature.parameterClause.parameters.map { param in
            (
                firstName: param.firstName.tokenKind != .wildcard ? param.firstName.trimmedDescription : nil,
                secondName: param.secondName?.trimmedDescription,
                type: param.type.trimmedDescription
            )
        }
    }

    /// Returns the return type string, or nil if Void.
    var returnTypeName: String? {
        signature.returnClause?.type.trimmedDescription
    }
}

// MARK: - Class/Struct Member Helpers

public extension DeclGroupSyntax {
    /// Extracts all stored property declarations from a type.
    var storedProperties: [VariableDeclSyntax] {
        memberBlock.members.compactMap { member in
            guard let varDecl = member.decl.as(VariableDeclSyntax.self),
                  varDecl.isStoredProperty else {
                return nil
            }
            return varDecl
        }
    }

    /// Extracts all function declarations.
    var functions: [FunctionDeclSyntax] {
        memberBlock.members.compactMap { member in
            member.decl.as(FunctionDeclSyntax.self)
        }
    }

    /// Returns the type name of this declaration.
    var typeName: String? {
        if let classDecl = self.as(ClassDeclSyntax.self) {
            return classDecl.name.trimmedDescription
        } else if let structDecl = self.as(StructDeclSyntax.self) {
            return structDecl.name.trimmedDescription
        } else if let enumDecl = self.as(EnumDeclSyntax.self) {
            return enumDecl.name.trimmedDescription
        } else if let actorDecl = self.as(ActorDeclSyntax.self) {
            return actorDecl.name.trimmedDescription
        }
        return nil
    }

    /// Whether this is a class declaration.
    var isClass: Bool {
        self.is(ClassDeclSyntax.self)
    }

    /// Whether this is a struct declaration.
    var isStruct: Bool {
        self.is(StructDeclSyntax.self)
    }

    /// Whether this is an enum declaration.
    var isEnum: Bool {
        self.is(EnumDeclSyntax.self)
    }

    /// Whether this is an actor declaration.
    var isActor: Bool {
        self.is(ActorDeclSyntax.self)
    }
}

// MARK: - Enum Case Helpers

public extension EnumDeclSyntax {
    /// Returns all enum case elements with their associated values.
    var caseElements: [EnumCaseElementSyntax] {
        memberBlock.members.flatMap { member -> [EnumCaseElementSyntax] in
            guard let caseDecl = member.decl.as(EnumCaseDeclSyntax.self) else {
                return []
            }
            return Array(caseDecl.elements)
        }
    }
}

// MARK: - Attribute Helpers

public extension AttributeSyntax {
    /// Extracts string literal arguments from the attribute.
    var stringArguments: [String] {
        guard case .argumentList(let args) = arguments else { return [] }
        return args.compactMap { arg in
            arg.expression.as(StringLiteralExprSyntax.self)?
                .segments.trimmedDescription
        }
    }

    /// Extracts integer literal arguments from the attribute.
    var intArguments: [Int] {
        guard case .argumentList(let args) = arguments else { return [] }
        return args.compactMap { arg in
            guard let intLiteral = arg.expression.as(IntegerLiteralExprSyntax.self) else {
                return nil
            }
            return Int(intLiteral.literal.trimmedDescription)
        }
    }

    /// Extracts float literal arguments from the attribute.
    var floatArguments: [Double] {
        guard case .argumentList(let args) = arguments else { return [] }
        return args.compactMap { arg in
            if let floatLiteral = arg.expression.as(FloatLiteralExprSyntax.self) {
                return Double(floatLiteral.literal.trimmedDescription)
            }
            if let intLiteral = arg.expression.as(IntegerLiteralExprSyntax.self) {
                return Double(intLiteral.literal.trimmedDescription)
            }
            return nil
        }
    }

    /// Returns labeled argument values as a dictionary.
    var labeledArguments: [(label: String?, expression: ExprSyntax)] {
        guard case .argumentList(let args) = arguments else { return [] }
        return args.map { arg in
            (label: arg.label?.trimmedDescription, expression: arg.expression)
        }
    }
}

// MARK: - Protocol Declaration Helpers

public extension ProtocolDeclSyntax {
    /// Returns all function requirements.
    var functionRequirements: [FunctionDeclSyntax] {
        memberBlock.members.compactMap { member in
            member.decl.as(FunctionDeclSyntax.self)
        }
    }

    /// Returns all property requirements.
    var propertyRequirements: [VariableDeclSyntax] {
        memberBlock.members.compactMap { member in
            member.decl.as(VariableDeclSyntax.self)
        }
    }
}
