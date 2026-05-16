// SwiftUIMacros.swift
// SwiftMacrosKit — SwiftUI & UI Macro Implementations
// Category: [G] SwiftUI & UI
// Author: SwiftMacrosKit Contributors

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

// MARK: - PreviewProviderMacro

public struct PreviewProviderMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard declaration.isStruct, let typeName = declaration.typeName else {
            context.addDiagnostic(.requiresStruct, at: node)
            return []
        }

        return ["""
        static var _previewContent: some View {
            Group {
                \(raw: typeName)()
                    .previewDisplayName("Default")
                \(raw: typeName)()
                    .previewDevice("iPhone 15 Pro")
                    .previewDisplayName("iPhone 15 Pro")
                \(raw: typeName)()
                    .previewDevice("iPad Pro (12.9-inch)")
                    .previewDisplayName("iPad Pro")
            }
        }
        """]
    }
}

// MARK: - ViewStateMacro

public struct ViewStateMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard declaration.isStruct, let typeName = declaration.typeName else {
            context.addDiagnostic(.requiresStruct, at: node)
            return []
        }

        let stateProps = declaration.storedProperties.filter { prop in
            prop.attributes.contains { attr in
                attr.as(AttributeSyntax.self)?.attributeName.trimmedDescription == "State"
            }
        }

        var structMembers = [String]()
        for prop in stateProps {
            guard let name = prop.propertyName,
                  let type = prop.propertyTypeName else { continue }
            let defaultVal = prop.initialValue?.trimmedDescription
            if let defaultVal = defaultVal {
                structMembers.append("var \(name): \(type) = \(defaultVal)")
            } else {
                structMembers.append("var \(name): \(type)")
            }
        }

        let membersStr = structMembers.joined(separator: "\n        ")

        return ["""
        struct ViewState {
            \(raw: membersStr)
        }
        """]
    }
}

// MARK: - BindablePlusMacro

public struct BindablePlusMacro: AccessorMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        // Marker macro — indicates property should be bindable
        return []
    }
}

// MARK: - StyleSheetMacro

public struct StyleSheetMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard declaration.isStruct, let typeName = declaration.typeName else {
            context.addDiagnostic(.requiresStruct, at: node)
            return []
        }

        return [
            "static let spacing4: CGFloat = 4",
            "static let spacing8: CGFloat = 8",
            "static let spacing16: CGFloat = 16",
            "static let spacing24: CGFloat = 24",
            "static let cornerRadius: CGFloat = 8",
        ]
    }
}

// MARK: - ThemedMacro

public struct ThemedMacro: MemberMacro {
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
            "@Environment(\\.colorScheme) private var colorScheme",
        ]
    }
}

// MARK: - AccessibleMacro

public struct AccessibleMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // Marker macro — modifiers are applied inline
        return []
    }
}

// MARK: - AnimatablePlusMacro

public struct AnimatablePlusMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard declaration.isStruct else {
            context.addDiagnostic(.requiresStruct, at: node)
            return []
        }

        let numericProps = declaration.storedProperties.filter { prop in
            let type = prop.propertyTypeName ?? ""
            return ["Double", "CGFloat", "Float"].contains(type)
        }

        guard let firstProp = numericProps.first,
              let name = firstProp.propertyName else {
            return []
        }

        return ["""
        var animatableData: Double {
            get { \(raw: name) }
            set { \(raw: name) = newValue }
        }
        """]
    }
}

// MARK: - HapticFeedbackMacro

public struct HapticFeedbackMacro: PeerMacro {
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
        let style = node.labeledArguments.first(where: { $0.label == "style" })?.expression.trimmedDescription ?? ".medium"

        return ["""
        func \(raw: name)WithHaptic() {
            #if canImport(UIKit)
            let generator = UIImpactFeedbackGenerator(style: \(raw: style))
            generator.impactOccurred()
            #endif
            \(raw: name)()
        }
        """]
    }
}

// MARK: - OrientationAwareMacro

public struct OrientationAwareMacro: MemberMacro {
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
            "@Environment(\\.horizontalSizeClass) private var horizontalSizeClass",
            "@Environment(\\.verticalSizeClass) private var verticalSizeClass",
            """
            var isLandscape: Bool {
                horizontalSizeClass == .regular && verticalSizeClass == .compact
            }
            """,
            """
            var isPortrait: Bool {
                !isLandscape
            }
            """,
        ]
    }
}

// MARK: - SafeAreaMacro

public struct SafeAreaMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard declaration.isStruct else {
            context.addDiagnostic(.requiresStruct, at: node)
            return []
        }

        return ["""
        private struct SafeAreaReader: ViewModifier {
            @Binding var insets: EdgeInsets
            func body(content: Content) -> some View {
                content.overlay(
                    GeometryReader { proxy in
                        Color.clear.onAppear {
                            insets = proxy.safeAreaInsets
                        }
                    }
                )
            }
        }
        """]
    }
}
