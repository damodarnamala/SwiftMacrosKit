// PatternTests.swift
// SwiftMacrosKit — Design Patterns Macro Tests

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(SwiftMacrosKitMacros)
@testable import SwiftMacrosKitMacros

let patternMacros: [String: Macro.Type] = [
    "Observer": ObserverMacro.self,
    "Command": CommandMacro.self,
    "Decorator": DecoratorMacro.self,
    "Composite": CompositeMacro.self,
    "Strategy": StrategyMacro.self,
    "StateMachine": StateMachineMacro.self,
    "EventBus": EventBusMacro.self,
    "Pipeline": PipelineMacro.self,
    "CQRS": CQRSMacro.self,
    "Repository": RepositoryMacro.self,
]

// MARK: - Observer Tests

final class ObserverTests: XCTestCase {
    func testObserverOnClass() throws {
        assertMacroExpansion(
            """
            @Observer
            class EventEmitter {
            }
            """,
            expandedSource: """
            class EventEmitter {

                private var observers: [ObjectIdentifier: (Any) -> Void] = [:]

                func addObserver<T: AnyObject>(_ observer: T, handler: @escaping (Any) -> Void) {
                    observers[ObjectIdentifier(observer)] = handler
                }

                func removeObserver<T: AnyObject>(_ observer: T) {
                    observers.removeValue(forKey: ObjectIdentifier(observer))
                }

                func notifyObservers(_ event: Any) {
                    for handler in observers.values {
                        handler(event)
                    }
                }
            }
            """,
            macros: patternMacros
        )
    }

    func testObserverOnStructEmitsError() throws {
        assertMacroExpansion(
            """
            @Observer
            struct EventEmitter {
            }
            """,
            expandedSource: """
            struct EventEmitter {
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: MacroError.requiresClass.message, line: 1, column: 1)
            ],
            macros: patternMacros
        )
    }
}

// MARK: - Command Tests

final class CommandTests: XCTestCase {
    func testCommandOnStruct() throws {
        assertMacroExpansion(
            """
            @Command
            struct SaveCommand {
            }
            """,
            expandedSource: """
            struct SaveCommand {

                func execute() {
                    // Override with command logic
                }

                func undo() {
                    // Override with undo logic
                }
            }
            """,
            macros: patternMacros
        )
    }

    func testCommandOnClassEmitsError() throws {
        assertMacroExpansion(
            """
            @Command
            class SaveCommand {
            }
            """,
            expandedSource: """
            class SaveCommand {
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: MacroError.requiresStruct.message, line: 1, column: 1)
            ],
            macros: patternMacros
        )
    }
}

// MARK: - Composite Tests

final class CompositeTests: XCTestCase {
    func testCompositeOnClass() throws {
        assertMacroExpansion(
            """
            @Composite
            class UIComponent {
            }
            """,
            expandedSource: """
            class UIComponent {

                var children: [UIComponent] = []

                func addChild(_ child: UIComponent) {
                    children.append(child)
                }

                func removeChild(at index: Int) {
                    children.remove(at: index)
                }

                func apply(_ operation: (UIComponent) -> Void) {
                    operation(self as! UIComponent)
                    for child in children {
                        child.apply(operation)
                    }
                }
            }
            """,
            macros: patternMacros
        )
    }
}

// MARK: - StateMachine Tests

final class StateMachineTests: XCTestCase {
    func testStateMachineOnClass() throws {
        assertMacroExpansion(
            """
            @StateMachine(states: "idle, loading, loaded, error")
            class ViewModel {
            }
            """,
            expandedSource: """
            class ViewModel {

                enum State: String, Hashable {
                    case idle, active, completed, failed
                }

                enum Event: String, Hashable {
                    case start, complete, fail, reset
                }

                private (set) var currentState: State = .idle

                func transition(via event: Event) -> Bool {
                    let transitions: [State: [Event: State]] = [
                        .idle: [.start: .active],
                        .active: [.complete: .completed, .fail: .failed],
                        .failed: [.reset: .idle],
                        .completed: [.reset: .idle]
                    ]
                    guard let nextState = transitions[currentState]? [event] else {
                        return false
                    }
                    currentState = nextState
                    return true
                }
            }
            """,
            macros: patternMacros
        )
    }

    func testStateMachineOnStructEmitsError() throws {
        assertMacroExpansion(
            """
            @StateMachine(states: "a, b")
            struct Config {
            }
            """,
            expandedSource: """
            struct Config {
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: MacroError.requiresClass.message, line: 1, column: 1)
            ],
            macros: patternMacros
        )
    }
}

// MARK: - EventBus Tests

final class EventBusTests: XCTestCase {
    func testEventBusExpansion() throws {
        assertMacroExpansion(
            """
            #EventBus(events: "userLoggedIn, dataLoaded")
            """,
            expandedSource: """

            final class EventBus<E: Hashable> {
                static var shared: EventBus<E> {
                    EventBus<E>()
                }
                private var handlers: [E: [(Any) -> Void]] = [:]
                func on(_ event: E, handler: @escaping (Any) -> Void) {
                    handlers[event, default: []].append(handler)
                }
                func emit(_ event: E, data: Any = ()) {
                    handlers[event]?.forEach {
                        $0 (data)
                    }
                }
            }
            """,
            macros: patternMacros
        )
    }
}

// MARK: - Pipeline Tests

final class PipelineTests: XCTestCase {
    func testPipelineOnFunction() throws {
        assertMacroExpansion(
            """
            @Pipeline
            func transform() {
            }
            """,
            expandedSource: """
            func transform() {
            }

            static func pipeline_transform<Input, Output>(
                _ stages: [(Input) -> Input],
                final: (Input) -> Output,
                input: Input
            ) -> Output {
                let intermediate = stages.reduce(input) {
                    $1 ($0)
                }
                return final(intermediate)
            }
            """,
            macros: patternMacros
        )
    }

    func testPipelineOnStructEmitsError() throws {
        assertMacroExpansion(
            """
            @Pipeline
            struct Config {
            }
            """,
            expandedSource: """
            struct Config {
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: MacroError.requiresFunction.message, line: 1, column: 1)
            ],
            macros: patternMacros
        )
    }
}

// MARK: - CQRS Tests

final class CQRSTests: XCTestCase {
    func testCQRSOnClass() throws {
        assertMacroExpansion(
            """
            @CQRS
            class UserService {
            }
            """,
            expandedSource: """
            class UserService {

                struct CommandHandler {
                    func handle(_ command: String) {
                        // Process command
                    }
                }

                struct QueryHandler {
                    func handle(_ query: String) -> Any? {
                        // Process query
                        return nil
                    }
                }

                let commandHandler = CommandHandler()

                let queryHandler = QueryHandler()
            }
            """,
            macros: patternMacros
        )
    }

    func testCQRSOnStructEmitsError() throws {
        assertMacroExpansion(
            """
            @CQRS
            struct UserService {
            }
            """,
            expandedSource: """
            struct UserService {
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: MacroError.requiresClass.message, line: 1, column: 1)
            ],
            macros: patternMacros
        )
    }
}

#endif
