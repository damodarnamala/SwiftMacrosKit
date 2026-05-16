// TestingMacros.swift
// SwiftMacrosKit — Testing & Mocking Macro Implementations
// Category: [F] Testing & Mocking
// Author: SwiftMacrosKit Contributors

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

// MARK: - MockMacro

public struct MockMacro: PeerMacro {
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
        let mockName = "Mock\(protocolName)"

        var methodStubs = [String]()
        for funcReq in protocolDecl.functionRequirements {
            let name = funcReq.functionName
            let params = funcReq.signature.parameterClause.trimmedDescription
            let returnClause = funcReq.signature.returnClause?.trimmedDescription ?? ""
            let effectSpecs = funcReq.signature.effectSpecifiers?.trimmedDescription ?? ""
            let returnDefault = funcReq.returnTypeName.map { " return returnValues[\"\(name)\"] as! \($0)" } ?? ""

            methodStubs.append("""
                func \(name)\(params) \(effectSpecs) \(returnClause) {
                    callLog.append("\(name)")
                   \(returnDefault)
                }
            """)
        }

        let stubs = methodStubs.joined(separator: "\n    ")

        return ["""
        class \(raw: mockName): \(raw: protocolName) {
            var callLog: [String] = []
            var returnValues: [String: Any] = [:]
            \(raw: stubs)
        }
        """]
    }
}

// MARK: - SpyMacro

public struct SpyMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let classDecl = declaration.as(ClassDeclSyntax.self) else {
            context.addDiagnostic(.requiresClass, at: node)
            return []
        }

        let className = classDecl.name.trimmedDescription
        let spyName = "Spy\(className)"

        var overrides = [String]()
        for funcDecl in classDecl.functions {
            let name = funcDecl.functionName
            let params = funcDecl.signature.parameterClause.trimmedDescription
            let returnClause = funcDecl.signature.returnClause?.trimmedDescription ?? ""
            let effectSpecs = funcDecl.signature.effectSpecifiers?.trimmedDescription ?? ""

            let paramForward = funcDecl.signature.parameterClause.parameters.map { param in
                let label = param.secondName?.trimmedDescription ?? param.firstName.trimmedDescription
                return "\(param.firstName.trimmedDescription): \(label)"
            }.joined(separator: ", ")

            let callPrefix = funcDecl.returnTypeName != nil ? "return " : ""
            let awaitPrefix = funcDecl.isAsync ? "await " : ""
            let tryPrefix = funcDecl.isThrowing ? "try " : ""

            overrides.append("""
                override func \(name)\(params) \(effectSpecs) \(returnClause) {
                    invocations.append("\(name)")
                    \(callPrefix)\(tryPrefix)\(awaitPrefix)super.\(name)(\(paramForward))
                }
            """)
        }

        let overridesStr = overrides.joined(separator: "\n    ")

        return ["""
        class \(raw: spyName): \(raw: className) {
            var invocations: [String] = []
            \(raw: overridesStr)
        }
        """]
    }
}

// MARK: - StubMacro

public struct StubMacro: PeerMacro {
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
        let returnType = funcDecl.returnTypeName ?? "Void"
        let args = node.labeledArguments
        let returnValue = args.first(where: { $0.label == "returning" })?.expression.trimmedDescription
            ?? args.first?.expression.trimmedDescription ?? "()"

        return ["""
        func stubbed_\(raw: name)() -> \(raw: returnType) {
            return \(raw: returnValue)
        }
        """]
    }
}

// MARK: - TestFixtureMacro

public struct TestFixtureMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard declaration.isStruct || declaration.isClass else {
            context.addDiagnostic(.requiresStructOrClass, at: node)
            return []
        }

        guard let typeName = declaration.typeName else { return [] }
        let properties = declaration.storedProperties

        var params = [String]()
        var args = [String]()

        for prop in properties {
            guard let name = prop.propertyName,
                  let type = prop.propertyTypeName else { continue }

            let defaultVal: String
            if let initial = prop.initialValue {
                defaultVal = initial.trimmedDescription
            } else if prop.isOptional {
                defaultVal = "nil"
            } else {
                switch type {
                case "String": defaultVal = "\"\""
                case "Int", "Int8", "Int16", "Int32", "Int64": defaultVal = "0"
                case "Double", "Float", "CGFloat": defaultVal = "0.0"
                case "Bool": defaultVal = "false"
                default: defaultVal = ".init()"
                }
            }

            params.append("\(name): \(type) = \(defaultVal)")
            args.append("\(name): \(name)")
        }

        let paramsStr = params.joined(separator: ", ")
        let argsStr = args.joined(separator: ", ")

        return ["""
        static func fixture(\(raw: paramsStr)) -> \(raw: typeName) {
            \(raw: typeName)(\(raw: argsStr))
        }
        """]
    }
}

// MARK: - SnapshotMacro

public struct SnapshotMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            context.addDiagnostic(.requiresStruct, at: node)
            return []
        }

        let viewName = structDecl.name.trimmedDescription

        return ["""
        #if canImport(XCTest) && canImport(SwiftUI)
        import XCTest
        import SwiftUI
        extension \(raw: viewName) {
            @MainActor
            static func snapshotTest(named name: String = "\(raw: viewName)") {
                let view = \(raw: viewName)()
                let controller = UIHostingController(rootView: view)
                controller.view.frame = UIScreen.main.bounds
                _ = controller.view.snapshotView(afterScreenUpdates: true)
            }
        }
        #endif
        """]
    }
}

// MARK: - GivenMacro / WhenMacro / ThenMacro

public struct GivenMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        guard let closure = node.trailingClosure else {
            context.addDiagnostic(.missingArguments, at: node)
            return "()"
        }
        let description = node.argumentList.first?.expression.trimmedDescription ?? "\"Given\""
        return """
        {
            print("GIVEN:", \(raw: description))
            \(closure.statements)
        }()
        """
    }
}

public struct WhenMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        guard let closure = node.trailingClosure else {
            context.addDiagnostic(.missingArguments, at: node)
            return "()"
        }
        let description = node.argumentList.first?.expression.trimmedDescription ?? "\"When\""
        return """
        {
            print("WHEN:", \(raw: description))
            \(closure.statements)
        }()
        """
    }
}

public struct ThenMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        guard let closure = node.trailingClosure else {
            context.addDiagnostic(.missingArguments, at: node)
            return "()"
        }
        let description = node.argumentList.first?.expression.trimmedDescription ?? "\"Then\""
        return """
        {
            print("THEN:", \(raw: description))
            \(closure.statements)
        }()
        """
    }
}

// MARK: - BenchmarkMacro

public struct BenchmarkMacro: PeerMacro {
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

        return ["""
        func benchmark_\(raw: name)() {
            let start = CFAbsoluteTimeGetCurrent()
            for _ in 0..<100 {
                \(raw: name)()
            }
            let elapsed = CFAbsoluteTimeGetCurrent() - start
            print("Benchmark \\(\(literal: name)): \\(elapsed / 100)s avg over 100 iterations")
        }
        """]
    }
}

// MARK: - AssertThrowsMacro

public struct AssertThrowsMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        guard let errorTypeArg = node.argumentList.first?.expression,
              let closure = node.trailingClosure else {
            context.addDiagnostic(.missingArguments, at: node)
            return "()"
        }

        return """
        {
            do {
                _ = try await {
                    \(closure.statements)
                }()
                XCTFail("Expected error of type \\(\(errorTypeArg).self) but no error was thrown")
            } catch is \(errorTypeArg) {
                // Expected
            } catch {
                XCTFail("Expected error of type \\(\(errorTypeArg).self) but got \\(error)")
            }
        }()
        """
    }
}
