// DiagnosticHelpers.swift
// SwiftMacrosKit — Diagnostic Emission Utilities
// Author: SwiftMacrosKit Contributors

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

public extension MacroExpansionContext {
    /// Convenience to emit a MacroError diagnostic at a given node.
    func addDiagnostic(_ error: MacroError, at node: some SyntaxProtocol) {
        addDiagnostics(from: MacroDiagnosticError(error: error), node: node)
    }
}

/// Wraps MacroError as a Swift Error for use with addDiagnostics(from:node:).
public struct MacroDiagnosticError: Error, DiagnosticMessage {
    public let error: MacroError

    public init(error: MacroError) {
        self.error = error
    }

    public var message: String { error.message }
    public var diagnosticID: MessageID { error.diagnosticID }
    public var severity: DiagnosticSeverity { error.severity }
}
