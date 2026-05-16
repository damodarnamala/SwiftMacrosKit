// AsyncTests.swift
// SwiftMacrosKit — Async & Concurrency Macro Tests
// Category: [C] Async & Concurrency
// Author: SwiftMacrosKit Contributors

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(SwiftMacrosKitMacros)
@testable import SwiftMacrosKitMacros

let asyncMacros: [String: Macro.Type] = [
    "Retry": RetryMacro.self,
    "Timeout": TimeoutMacro.self,
    "Debounce": DebounceMacro.self,
    "Throttle": ThrottleMacro.self,
    "BackgroundActor": BackgroundActorMacro.self,
    "AsyncCached": AsyncCachedMacro.self,
    "RateLimit": RateLimitMacro.self,
    "Concurrent": ConcurrentMacro.self,
    "Serial": SerialMacro.self,
]

// MARK: - RetryMacro Tests

final class RetryMacroTests: XCTestCase {
    func testRetryOnAsyncFunction() throws {
        assertMacroExpansion(
            """
            @Retry(attempts: 5, delay: 2.0)
            func fetchData() async throws -> String {
                return "data"
            }
            """,
            expandedSource: """
            func fetchData() async throws -> String {
                return "data"
            }

            func _retrying_fetchData() async throws -> String {
                var lastError: Error?
                for attempt in 1 ... 5 {
                    do {
                        return try await fetchData()
                    } catch {
                        lastError = error
                        if attempt < 5 {
                            try await Task.sleep(nanoseconds: UInt64(2.0 * 1_000_000_000))
                        }
                    }
                }
                throw lastError!
            }
            """,
            macros: asyncMacros
        )
    }

    func testRetryOnNonFunctionEmitsError() throws {
        assertMacroExpansion(
            """
            @Retry(attempts: 3, delay: 1.0)
            struct NotAFunction {
            }
            """,
            expandedSource: """
            struct NotAFunction {
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: MacroError.requiresFunction.message, line: 1, column: 1)
            ],
            macros: asyncMacros
        )
    }

    func testRetryWithDefaultArguments() throws {
        assertMacroExpansion(
            """
            @Retry
            func load() async throws {
            }
            """,
            expandedSource: """
            func load() async throws {
            }

            func _retrying_load() async throws  {
                var lastError: Error?
                for attempt in 1 ... 3 {
                    do {
                        return try await load()
                    } catch {
                        lastError = error
                        if attempt < 3 {
                            try await Task.sleep(nanoseconds: UInt64(1.0 * 1_000_000_000))
                        }
                    }
                }
                throw lastError!
            }
            """,
            macros: asyncMacros
        )
    }
}

// MARK: - TimeoutMacro Tests

final class TimeoutMacroTests: XCTestCase {
    func testTimeoutOnAsyncFunction() throws {
        assertMacroExpansion(
            """
            @Timeout(seconds: 10)
            func fetchUser() async throws -> String {
                return ""
            }
            """,
            expandedSource: """
            func fetchUser() async throws -> String {
                return ""
            }

            func _withTimeout_fetchUser() async throws -> String {
                try await withThrowingTaskGroup(of: String.self) { group in
                    group.addTask {
                        try await self.fetchUser()
                    }
                    group.addTask {
                        try await Task.sleep(nanoseconds: UInt64(10 * 1_000_000_000))
                        throw CancellationError()
                    }
                    let result = try await group.next()!
                    group.cancelAll()
                    return result
                }
            }
            """,
            macros: asyncMacros
        )
    }

    func testTimeoutOnNonFunctionEmitsError() throws {
        assertMacroExpansion(
            """
            @Timeout(seconds: 5)
            var value: Int = 0
            """,
            expandedSource: """
            var value: Int = 0
            """,
            diagnostics: [
                DiagnosticSpec(message: MacroError.requiresAsyncFunction.message, line: 1, column: 1)
            ],
            macros: asyncMacros
        )
    }

    func testTimeoutWithDefaultSeconds() throws {
        assertMacroExpansion(
            """
            @Timeout
            func process() async throws -> Int {
                return 42
            }
            """,
            expandedSource: """
            func process() async throws -> Int {
                return 42
            }

            func _withTimeout_process() async throws -> Int {
                try await withThrowingTaskGroup(of: Int.self) { group in
                    group.addTask {
                        try await self.process()
                    }
                    group.addTask {
                        try await Task.sleep(nanoseconds: UInt64(30 * 1_000_000_000))
                        throw CancellationError()
                    }
                    let result = try await group.next()!
                    group.cancelAll()
                    return result
                }
            }
            """,
            macros: asyncMacros
        )
    }
}

// MARK: - DebounceMacro Tests

final class DebounceMacroTests: XCTestCase {
    func testDebounceOnFunction() throws {
        assertMacroExpansion(
            """
            @Debounce(seconds: 0.5)
            func search() {
            }
            """,
            expandedSource: """
            func search() {
            }

            private var _debounce_search_task: Task<Void, Never>?

            func debounced_search() {
                _debounce_search_task?.cancel()
                _debounce_search_task = Task {
                    try? await Task.sleep(nanoseconds: UInt64(0.5 * 1_000_000_000))
                    guard !Task.isCancelled else {
                        return
                    }
                    search()
                }
            }
            """,
            macros: asyncMacros
        )
    }

    func testDebounceOnNonFunctionEmitsError() throws {
        assertMacroExpansion(
            """
            @Debounce(seconds: 0.3)
            class MyClass {
            }
            """,
            expandedSource: """
            class MyClass {
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: MacroError.requiresFunction.message, line: 1, column: 1)
            ],
            macros: asyncMacros
        )
    }

    func testDebounceWithDefaultSeconds() throws {
        assertMacroExpansion(
            """
            @Debounce
            func update() {
            }
            """,
            expandedSource: """
            func update() {
            }

            private var _debounce_update_task: Task<Void, Never>?

            func debounced_update() {
                _debounce_update_task?.cancel()
                _debounce_update_task = Task {
                    try? await Task.sleep(nanoseconds: UInt64(0.3 * 1_000_000_000))
                    guard !Task.isCancelled else {
                        return
                    }
                    update()
                }
            }
            """,
            macros: asyncMacros
        )
    }
}

// MARK: - ThrottleMacro Tests

final class ThrottleMacroTests: XCTestCase {
    func testThrottleOnFunction() throws {
        assertMacroExpansion(
            """
            @Throttle(seconds: 2.0)
            func refresh() {
            }
            """,
            expandedSource: """
            func refresh() {
            }

            private var _throttle_refresh_lastCall: Date?

            func throttled_refresh() {
                let now = Date()
                if let last = _throttle_refresh_lastCall,
                   now.timeIntervalSince(last) < 2.0 {
                    return
                }
                _throttle_refresh_lastCall = now
                refresh()
            }
            """,
            macros: asyncMacros
        )
    }

    func testThrottleOnNonFunctionEmitsError() throws {
        assertMacroExpansion(
            """
            @Throttle(seconds: 1.0)
            enum Direction {
            }
            """,
            expandedSource: """
            enum Direction {
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: MacroError.requiresFunction.message, line: 1, column: 1)
            ],
            macros: asyncMacros
        )
    }

    func testThrottleWithDefaultSeconds() throws {
        assertMacroExpansion(
            """
            @Throttle
            func tap() {
            }
            """,
            expandedSource: """
            func tap() {
            }

            private var _throttle_tap_lastCall: Date?

            func throttled_tap() {
                let now = Date()
                if let last = _throttle_tap_lastCall,
                   now.timeIntervalSince(last) < 1.0 {
                    return
                }
                _throttle_tap_lastCall = now
                tap()
            }
            """,
            macros: asyncMacros
        )
    }
}

// MARK: - BackgroundActorMacro Tests

final class BackgroundActorMacroTests: XCTestCase {
    func testBackgroundActorOnFunction() throws {
        assertMacroExpansion(
            """
            @BackgroundActor
            func doWork() {
            }
            """,
            expandedSource: """
            func doWork() {
            }

            @globalActor
            actor BackgroundActor {
                static let shared = BackgroundActor()
            }
            """,
            macros: asyncMacros
        )
    }

    func testBackgroundActorOnNonFunctionEmitsError() throws {
        assertMacroExpansion(
            """
            @BackgroundActor
            var value: Int = 0
            """,
            expandedSource: """
            var value: Int = 0
            """,
            diagnostics: [
                DiagnosticSpec(message: MacroError.requiresFunction.message, line: 1, column: 1)
            ],
            macros: asyncMacros
        )
    }

    func testBackgroundActorOnClass() throws {
        assertMacroExpansion(
            """
            @BackgroundActor
            class Worker {
            }
            """,
            expandedSource: """
            class Worker {
            }

            @globalActor
            actor BackgroundActor {
                static let shared = BackgroundActor()
            }
            """,
            macros: asyncMacros
        )
    }
}

// MARK: - AsyncCachedMacro Tests

final class AsyncCachedMacroTests: XCTestCase {
    func testAsyncCachedOnFunction() throws {
        assertMacroExpansion(
            """
            @AsyncCached
            func fetchProfile() async throws -> String {
                return "profile"
            }
            """,
            expandedSource: """
            func fetchProfile() async throws -> String {
                return "profile"
            }

            private var _cache_fetchProfile: String?

            func cached_fetchProfile() async throws -> String {
                if let cached = _cache_fetchProfile {
                    return cached
                }
                let result = try await fetchProfile()
                _cache_fetchProfile = result
                return result
            }

            func invalidate_fetchProfile() {
                _cache_fetchProfile = nil
            }
            """,
            macros: asyncMacros
        )
    }

    func testAsyncCachedOnNonFunctionEmitsError() throws {
        assertMacroExpansion(
            """
            @AsyncCached
            struct Config {
            }
            """,
            expandedSource: """
            struct Config {
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: MacroError.requiresAsyncFunction.message, line: 1, column: 1)
            ],
            macros: asyncMacros
        )
    }

    func testAsyncCachedNoReturnType() throws {
        assertMacroExpansion(
            """
            @AsyncCached
            func syncData() async throws {
            }
            """,
            expandedSource: """
            func syncData() async throws {
            }

            private var _cache_syncData: Void?

            func cached_syncData() async throws -> Void {
                if let cached = _cache_syncData {
                    return cached
                }
                let result = try await syncData()
                _cache_syncData = result
                return result
            }

            func invalidate_syncData() {
                _cache_syncData = nil
            }
            """,
            macros: asyncMacros
        )
    }
}

// MARK: - RateLimitMacro Tests

final class RateLimitMacroTests: XCTestCase {
    func testRateLimitOnFunction() throws {
        assertMacroExpansion(
            """
            @RateLimit(calls: 5, per: 30)
            func sendRequest() {
            }
            """,
            expandedSource: """
            func sendRequest() {
            }

            private var _rateLimit_sendRequest_timestamps: [Date] = []

            func rateLimited_sendRequest() throws {
                let now = Date()
                _rateLimit_sendRequest_timestamps = _rateLimit_sendRequest_timestamps.filter {
                    now.timeIntervalSince($0) < 30
                }
                guard _rateLimit_sendRequest_timestamps.count < 5 else {
                    fatalError("Rate limit exceeded for sendRequest")
                }
                _rateLimit_sendRequest_timestamps.append(now)
                sendRequest()
            }
            """,
            macros: asyncMacros
        )
    }

    func testRateLimitOnNonFunctionEmitsError() throws {
        assertMacroExpansion(
            """
            @RateLimit(calls: 10, per: 60)
            var counter: Int = 0
            """,
            expandedSource: """
            var counter: Int = 0
            """,
            diagnostics: [
                DiagnosticSpec(message: MacroError.requiresFunction.message, line: 1, column: 1)
            ],
            macros: asyncMacros
        )
    }

    func testRateLimitWithDefaultArguments() throws {
        assertMacroExpansion(
            """
            @RateLimit
            func ping() {
            }
            """,
            expandedSource: """
            func ping() {
            }

            private var _rateLimit_ping_timestamps: [Date] = []

            func rateLimited_ping() throws {
                let now = Date()
                _rateLimit_ping_timestamps = _rateLimit_ping_timestamps.filter {
                    now.timeIntervalSince($0) < 60
                }
                guard _rateLimit_ping_timestamps.count < 10 else {
                    fatalError("Rate limit exceeded for ping")
                }
                _rateLimit_ping_timestamps.append(now)
                ping()
            }
            """,
            macros: asyncMacros
        )
    }
}

// MARK: - ConcurrentMacro Tests

final class ConcurrentMacroTests: XCTestCase {
    func testConcurrentOnFunction() throws {
        assertMacroExpansion(
            """
            @Concurrent
            func process() async throws -> Int {
                return 1
            }
            """,
            expandedSource: """
            func process() async throws -> Int {
                return 1
            }

            func concurrent_process<T>(items: [T], transform: @Sendable @escaping (T) async throws -> Int) async throws -> [Int] {
                try await withThrowingTaskGroup(of: Int.self) { group in
                    for item in items {
                        group.addTask {
                            try await transform(item)
                        }
                    }
                    var results: [Int] = []
                    for try await result in group {
                        results.append(result)
                    }
                    return results
                }
            }
            """,
            macros: asyncMacros
        )
    }

    func testConcurrentOnNonFunctionEmitsError() throws {
        assertMacroExpansion(
            """
            @Concurrent
            struct Batch {
            }
            """,
            expandedSource: """
            struct Batch {
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: MacroError.requiresFunction.message, line: 1, column: 1)
            ],
            macros: asyncMacros
        )
    }

    func testConcurrentNoReturnType() throws {
        assertMacroExpansion(
            """
            @Concurrent
            func execute() async throws {
            }
            """,
            expandedSource: """
            func execute() async throws {
            }

            func concurrent_execute<T>(items: [T], transform: @Sendable @escaping (T) async throws -> Void) async throws -> [Void] {
                try await withThrowingTaskGroup(of: Void.self) { group in
                    for item in items {
                        group.addTask {
                            try await transform(item)
                        }
                    }
                    var results: [Void] = []
                    for try await result in group {
                        results.append(result)
                    }
                    return results
                }
            }
            """,
            macros: asyncMacros
        )
    }
}

// MARK: - SerialMacro Tests

final class SerialMacroTests: XCTestCase {
    func testSerialOnClass() throws {
        assertMacroExpansion(
            """
            @Serial
            class TaskRunner {
            }
            """,
            expandedSource: """
            class TaskRunner {

                private let _serialQueue = DispatchQueue(label: "serial.queue")

                func enqueue(_ operation: @escaping () -> Void) {
                    _serialQueue.async {
                        operation()
                    }
                }
            }
            """,
            macros: asyncMacros
        )
    }

    func testSerialOnStructEmitsError() throws {
        assertMacroExpansion(
            """
            @Serial
            struct NotValid {
            }
            """,
            expandedSource: """
            struct NotValid {
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: MacroError.requiresActorOrClass.message, line: 1, column: 1)
            ],
            macros: asyncMacros
        )
    }

    func testSerialOnActor() throws {
        assertMacroExpansion(
            """
            @Serial
            actor Coordinator {
            }
            """,
            expandedSource: """
            actor Coordinator {

                private let _serialQueue = DispatchQueue(label: "serial.queue")

                func enqueue(_ operation: @escaping () -> Void) {
                    _serialQueue.async {
                        operation()
                    }
                }
            }
            """,
            macros: asyncMacros
        )
    }
}

#else

final class AsyncMacrosFallbackTests: XCTestCase {
    func testMacrosUnavailable() throws {
        XCTSkip("Macros are only supported when compiled with a host compiler")
    }
}

#endif
