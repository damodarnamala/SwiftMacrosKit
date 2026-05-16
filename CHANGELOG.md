# Changelog

All notable changes to SwiftMacrosKit will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-07-17

### Added

- **100 Swift Macros** organized into 11 categories
- **[A] Creational Patterns** (12 macros): Singleton, Builder, Factory, Prototype, FluentBuilder, StaticFactory, AutoInit, DefaultInit, LazyInit, Pool, Multiton, Injectable
- **[B] Validation & Constraints** (10 macros): Validated, NonEmpty, Clamped, RegexValidated, Email, URLValidated, MinLength, MaxLength, NotNil, Range
- **[C] Async & Concurrency** (9 macros): Retry, Timeout, Debounce, Throttle, BackgroundActor, AsyncCached, RateLimit, Concurrent, Serial
- **[D] Persistence & Storage** (8 macros): UserDefault, Keychain, CloudSync, FileStored, Persisted, CoreDataEntity, SwiftDataModel, Cached
- **[E] Networking** (8 macros): Endpoint, GET, POST, Headers, Bearer, Multipart, MockResponse, QueryParam
- **[F] Testing & Mocking** (10 macros): Mock, Spy, Stub, TestFixture, Snapshot, Benchmark, Given, When, Then, AssertThrows
- **[G] SwiftUI & UI** (10 macros): PreviewProvider, ViewState, StyleSheet, Themed, AnimatablePlus, OrientationAware, SafeArea, BindablePlus, Accessible, HapticFeedback
- **[H] Security** (6 macros): Encrypted, Hashed, Redacted, Sanitized, BiometricGated, SecureEnclave
- **[I] Logging & Observability** (6 macros): Logged, Traced, Measured, OSLogged, Crashlytic, Analytics
- **[J] Design Patterns** (10 macros): Observer, Command, Decorator, Composite, Strategy, StateMachine, EventBus, Pipeline, CQRS, Repository
- **[K] Utilities & DX** (10 macros): EquatablePlus, ComparablePlus, Copyable, StringConvertible, CaseIterablePlus, Defaultable, DecodablePlus, EncodablePlus, Flagged, DeprecatedPlus
- Shared diagnostic infrastructure with descriptive error messages
- Shared syntax helpers for common AST operations
- Comprehensive test suite with 190 tests (3+ per macro using `assertMacroExpansion`)
- Platform support: iOS 17+, macOS 14+, tvOS 17+, watchOS 10+
