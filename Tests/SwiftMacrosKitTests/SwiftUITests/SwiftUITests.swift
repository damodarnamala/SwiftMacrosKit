// SwiftUITests.swift
// SwiftMacrosKit — SwiftUI & UI Macro Tests

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(SwiftMacrosKitMacros)
@testable import SwiftMacrosKitMacros

let swiftUIMacros: [String: Macro.Type] = [
    "PreviewProvider": PreviewProviderMacro.self,
    "ViewState": ViewStateMacro.self,
    "StyleSheet": StyleSheetMacro.self,
    "Themed": ThemedMacro.self,
    "AnimatablePlus": AnimatablePlusMacro.self,
    "OrientationAware": OrientationAwareMacro.self,
    "SafeArea": SafeAreaMacro.self,
    "BindablePlus": BindablePlusMacro.self,
    "Accessible": AccessibleMacro.self,
    "HapticFeedback": HapticFeedbackMacro.self,
]

// MARK: - PreviewProvider Tests

final class PreviewProviderTests: XCTestCase {
    func testPreviewProviderOnStruct() throws {
        assertMacroExpansion(
            """
            @PreviewProvider
            struct ContentView {
            }
            """,
            expandedSource: """
            struct ContentView {

                static var _previewContent: some View {
                    Group {
                        ContentView()
                            .previewDisplayName("Default")
                        ContentView()
                            .previewDevice("iPhone 15 Pro")
                            .previewDisplayName("iPhone 15 Pro")
                        ContentView()
                            .previewDevice("iPad Pro (12.9-inch)")
                            .previewDisplayName("iPad Pro")
                    }
                }
            }
            """,
            macros: swiftUIMacros
        )
    }

    func testPreviewProviderOnClassEmitsError() throws {
        assertMacroExpansion(
            """
            @PreviewProvider
            class MyView {
            }
            """,
            expandedSource: """
            class MyView {
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: MacroError.requiresStruct.message, line: 1, column: 1)
            ],
            macros: swiftUIMacros
        )
    }
}

// MARK: - StyleSheet Tests

final class StyleSheetTests: XCTestCase {
    func testStyleSheetOnStruct() throws {
        assertMacroExpansion(
            """
            @StyleSheet
            struct AppStyles {
            }
            """,
            expandedSource: """
            struct AppStyles {

                static let spacing4: CGFloat = 4

                static let spacing8: CGFloat = 8

                static let spacing16: CGFloat = 16

                static let spacing24: CGFloat = 24

                static let cornerRadius: CGFloat = 8
            }
            """,
            macros: swiftUIMacros
        )
    }

    func testStyleSheetOnClassEmitsError() throws {
        assertMacroExpansion(
            """
            @StyleSheet
            class AppStyles {
            }
            """,
            expandedSource: """
            class AppStyles {
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: MacroError.requiresStruct.message, line: 1, column: 1)
            ],
            macros: swiftUIMacros
        )
    }
}

// MARK: - Themed Tests

final class ThemedTests: XCTestCase {
    func testThemedOnStruct() throws {
        assertMacroExpansion(
            """
            @Themed
            struct ContentView {
            }
            """,
            expandedSource: """
            struct ContentView {

                @Environment(\\.colorScheme) private var colorScheme
            }
            """,
            macros: swiftUIMacros
        )
    }

    func testThemedOnClassEmitsError() throws {
        assertMacroExpansion(
            """
            @Themed
            class ContentView {
            }
            """,
            expandedSource: """
            class ContentView {
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: MacroError.requiresStruct.message, line: 1, column: 1)
            ],
            macros: swiftUIMacros
        )
    }
}

// MARK: - HapticFeedback Tests

final class HapticFeedbackTests: XCTestCase {
    func testHapticFeedbackOnFunction() throws {
        assertMacroExpansion(
            """
            @HapticFeedback(style: .heavy)
            func buttonTapped() {
            }
            """,
            expandedSource: """
            func buttonTapped() {
            }

            func buttonTappedWithHaptic() {
                #if canImport (UIKit)
                let generator = UIImpactFeedbackGenerator(style: .heavy)
                generator.impactOccurred()
                #endif
                buttonTapped()
            }
            """,
            macros: swiftUIMacros
        )
    }

    func testHapticFeedbackOnStructEmitsError() throws {
        assertMacroExpansion(
            """
            @HapticFeedback
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
            macros: swiftUIMacros
        )
    }
}

// MARK: - BindablePlus Tests

final class BindablePlusTests: XCTestCase {
    func testBindablePlusIsMarker() throws {
        assertMacroExpansion(
            """
            @BindablePlus var value: Int = 0
            """,
            expandedSource: """
            var value: Int = 0
            """,
            macros: swiftUIMacros
        )
    }
}

// MARK: - Accessible Tests

final class AccessibleTests: XCTestCase {
    func testAccessibleIsMarker() throws {
        assertMacroExpansion(
            """
            @Accessible
            struct MyView {
            }
            """,
            expandedSource: """
            struct MyView {
            }
            """,
            macros: swiftUIMacros
        )
    }
}

#endif
