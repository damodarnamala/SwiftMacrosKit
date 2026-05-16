// PatternMacroDeclarations.swift
// SwiftMacrosKit — Design Patterns Macro Declarations
// Category: [J] Design Patterns
// Author: SwiftMacrosKit Contributors

/// Generates an observer list with subscribe/notify helpers.
///
/// **Usage:** `@Observer class EventEmitter { ... }`
@attached(member, names: named(observers), named(addObserver), named(removeObserver), named(notifyObservers))
public macro Observer() = #externalMacro(module: "SwiftMacrosKitMacros", type: "ObserverMacro")

/// Encapsulates methods as undoable command objects.
///
/// **Usage:** `@Command struct SaveCommand { ... }`
@attached(member, names: named(execute), named(undo))
public macro Command() = #externalMacro(module: "SwiftMacrosKitMacros", type: "CommandMacro")

/// Creates a wrapper type that intercepts calls for decoration.
///
/// **Usage:** `@Decorator protocol Drawable { ... }`
@attached(member, names: named(wrapped))
public macro Decorator() = #externalMacro(module: "SwiftMacrosKitMacros", type: "DecoratorMacro")

/// Adds children array and leaf/composite helpers.
///
/// **Usage:** `@Composite class UIComponent { ... }`
@attached(member, names: named(children), named(add), named(remove))
public macro Composite() = #externalMacro(module: "SwiftMacrosKitMacros", type: "CompositeMacro")

/// Generates a peer protocol + context for swappable algorithms.
///
/// **Usage:** `@Strategy struct SortingStrategy { ... }`
@attached(peer, names: suffixed(Protocol), suffixed(Context))
public macro Strategy() = #externalMacro(module: "SwiftMacrosKitMacros", type: "StrategyMacro")

/// Adds a state enum, transition method, and validation for state machines.
///
/// - Parameter states: Comma-separated list of state names.
///
/// **Usage:** `@StateMachine(states: "idle, loading, loaded, error") class ViewModel { ... }`
@attached(member, names: named(State), named(currentState), named(transition))
public macro StateMachine(states: String) = #externalMacro(module: "SwiftMacrosKitMacros", type: "StateMachineMacro")

/// Generates a type-safe event bus for publish/subscribe.
///
/// - Parameter events: Comma-separated list of event names.
///
/// **Usage:** `#EventBus(events: "userLoggedIn, dataLoaded")`
@freestanding(declaration, names: arbitrary)
public macro EventBus(events: String) = #externalMacro(module: "SwiftMacrosKitMacros", type: "EventBusMacro")

/// Creates a multi-stage pipeline for chaining transforms.
///
/// **Usage:** `@Pipeline struct ImagePipeline { ... }`
@attached(peer, names: suffixed(Runner))
public macro Pipeline() = #externalMacro(module: "SwiftMacrosKitMacros", type: "PipelineMacro")

/// Splits a struct into a command model and a query model (CQRS pattern).
///
/// **Usage:** `@CQRS struct UserService { ... }`
@attached(member, names: named(CommandModel), named(QueryModel))
public macro CQRS() = #externalMacro(module: "SwiftMacrosKitMacros", type: "CQRSMacro")

/// Generates a repository protocol and default implementation.
///
/// **Usage:** `@Repository struct User { ... }`
@attached(peer, names: suffixed(Repository), suffixed(RepositoryProtocol))
public macro Repository() = #externalMacro(module: "SwiftMacrosKitMacros", type: "RepositoryMacro")
