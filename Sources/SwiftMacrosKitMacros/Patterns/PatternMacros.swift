// PatternMacros.swift
// SwiftMacrosKit — Design Pattern Macro Implementations
// Category: [J] Design Patterns
// Author: SwiftMacrosKit Contributors

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

// MARK: - ObserverMacro

public struct ObserverMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard declaration.isClass, let typeName = declaration.typeName else {
            context.addDiagnostic(.requiresClass, at: node)
            return []
        }

        return [
            "private var observers: [ObjectIdentifier: (Any) -> Void] = [:]",
            """
            func addObserver<T: AnyObject>(_ observer: T, handler: @escaping (Any) -> Void) {
                observers[ObjectIdentifier(observer)] = handler
            }
            """,
            """
            func removeObserver<T: AnyObject>(_ observer: T) {
                observers.removeValue(forKey: ObjectIdentifier(observer))
            }
            """,
            """
            func notifyObservers(_ event: Any) {
                for handler in observers.values {
                    handler(event)
                }
            }
            """,
        ]
    }
}

// MARK: - CommandMacro

public struct CommandMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard declaration.isStruct else {
            context.addDiagnostic(.requiresStruct, at: node)
            return []
        }

        return [
            """
            func execute() {
                // Override with command logic
            }
            """,
            """
            func undo() {
                // Override with undo logic
            }
            """,
        ]
    }
}

// MARK: - DecoratorMacro

public struct DecoratorMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard declaration.isClass, let typeName = declaration.typeName else {
            context.addDiagnostic(.requiresClass, at: node)
            return []
        }

        return [
            "private let wrapped: Any",
            """
            init(wrapping base: Any) {
                self.wrapped = base
            }
            """,
        ]
    }
}

// MARK: - CompositeMacro

public struct CompositeMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let typeName = declaration.typeName else { return [] }

        return [
            "var children: [\(raw: typeName)] = []",
            """
            func addChild(_ child: \(raw: typeName)) {
                children.append(child)
            }
            """,
            """
            func removeChild(at index: Int) {
                children.remove(at: index)
            }
            """,
            """
            func apply(_ operation: (\(raw: typeName)) -> Void) {
                operation(self as! \(raw: typeName))
                for child in children {
                    child.apply(operation)
                }
            }
            """,
        ]
    }
}

// MARK: - StrategyMacro

public struct StrategyMacro: PeerMacro {
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

        return ["""
        class \(raw: protocolName)Context<S: \(raw: protocolName)> {
            private var strategy: S
            init(strategy: S) {
                self.strategy = strategy
            }
            func setStrategy(_ strategy: S) {
                self.strategy = strategy
            }
        }
        """]
    }
}

// MARK: - StateMachineMacro

public struct StateMachineMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard declaration.isClass else {
            context.addDiagnostic(.requiresClass, at: node)
            return []
        }

        let args = node.labeledArguments
        let statesExpr = args.first(where: { $0.label == "states" })?.expression.trimmedDescription ?? "[]"
        let transitionsExpr = args.first(where: { $0.label == "transitions" })?.expression.trimmedDescription ?? "[:]"

        return [
            "enum State: String, Hashable { case idle, active, completed, failed }",
            "enum Event: String, Hashable { case start, complete, fail, reset }",
            "private(set) var currentState: State = .idle",
            """
            func transition(via event: Event) -> Bool {
                let transitions: [State: [Event: State]] = [
                    .idle: [.start: .active],
                    .active: [.complete: .completed, .fail: .failed],
                    .failed: [.reset: .idle],
                    .completed: [.reset: .idle]
                ]
                guard let nextState = transitions[currentState]?[event] else {
                    return false
                }
                currentState = nextState
                return true
            }
            """,
        ]
    }
}

// MARK: - EventBusMacro

public struct EventBusMacro: DeclarationMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        return ["""
        final class EventBus<E: Hashable> {
            static var shared: EventBus<E> { EventBus<E>() }
            private var handlers: [E: [(Any) -> Void]] = [:]
            func on(_ event: E, handler: @escaping (Any) -> Void) {
                handlers[event, default: []].append(handler)
            }
            func emit(_ event: E, data: Any = ()) {
                handlers[event]?.forEach { $0(data) }
            }
        }
        """]
    }
}

// MARK: - PipelineMacro

public struct PipelineMacro: PeerMacro {
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
        static func pipeline_\(raw: name)<Input, Output>(
            _ stages: [(Input) -> Input],
            final: (Input) -> Output,
            input: Input
        ) -> Output {
            let intermediate = stages.reduce(input) { $1($0) }
            return final(intermediate)
        }
        """]
    }
}

// MARK: - CQRSMacro

public struct CQRSMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard declaration.isClass, let typeName = declaration.typeName else {
            context.addDiagnostic(.requiresClass, at: node)
            return []
        }

        return [
            """
            struct CommandHandler {
                func handle(_ command: String) {
                    // Process command
                }
            }
            """,
            """
            struct QueryHandler {
                func handle(_ query: String) -> Any? {
                    // Process query
                    return nil
                }
            }
            """,
            "let commandHandler = CommandHandler()",
            "let queryHandler = QueryHandler()",
        ]
    }
}

// MARK: - RepositoryMacro

public struct RepositoryMacro: PeerMacro {
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

        return ["""
        struct Default\(raw: protocolName): \(raw: protocolName) {
            func create(_ item: Any) async throws { }
            func read(id: String) async throws -> Any? { nil }
            func update(_ item: Any) async throws { }
            func delete(id: String) async throws { }
        }
        """]
    }
}
