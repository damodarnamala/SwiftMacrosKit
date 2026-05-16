// MacroError.swift
// SwiftMacrosKit — Shared Diagnostic Infrastructure
// Author: SwiftMacrosKit Contributors

import SwiftDiagnostics
import SwiftSyntax

/// Unified diagnostic error type for all SwiftMacrosKit macros.
public enum MacroError: String, DiagnosticMessage {
    // Attachment errors
    case requiresClass = "This macro can only be applied to a class"
    case requiresStruct = "This macro can only be applied to a struct"
    case requiresStructOrClass = "This macro can only be applied to a struct or class"
    case requiresEnum = "This macro can only be applied to an enum"
    case requiresProtocol = "This macro can only be applied to a protocol"
    case requiresFunction = "This macro can only be applied to a function"
    case requiresAsyncFunction = "This macro can only be applied to an async function"
    case requiresProperty = "This macro can only be applied to a stored property"
    case requiresStringProperty = "This macro can only be applied to a String property"
    case requiresNumericProperty = "This macro can only be applied to a numeric property"
    case requiresOptionalProperty = "This macro can only be applied to an optional property"
    case requiresArrayProperty = "This macro can only be applied to an Array property"
    case requiresCodableProperty = "This macro can only be applied to a Codable property"
    case requiresDataProperty = "This macro can only be applied to a Data property"
    case requiresStringOrArrayProperty = "This macro can only be applied to a String or Array property"
    case requiresView = "This macro can only be applied to a SwiftUI View struct"
    case requiresActorOrClass = "This macro can only be applied to an actor or class"
    case requiresComparableProperty = "This macro can only be applied to a Comparable property"

    // Argument errors
    case missingArguments = "This macro requires arguments"
    case invalidArguments = "Invalid macro arguments provided"
    case invalidRegexPattern = "The provided regex pattern is invalid"
    case invalidRangeValues = "Min value must be less than or equal to max value"
    case missingKey = "A key argument is required"
    case missingPath = "A path argument is required"
    case missingDefaultValue = "A default value argument is required"

    // Structural errors
    case noStoredProperties = "Type has no stored properties"
    case noEnumCases = "Enum has no cases"
    case noMethods = "Protocol/type has no methods"
    case notOnNotStruct = "This macro cannot be applied to structs"
    case notOnEnum = "This macro cannot be applied to enums"

    public var message: String { rawValue }

    public var diagnosticID: MessageID {
        MessageID(domain: "SwiftMacrosKit", id: rawValue)
    }

    public var severity: DiagnosticSeverity { .error }
}

/// Warning-level diagnostics.
public enum MacroWarning: String, DiagnosticMessage {
    case emptyExpansion = "Macro expansion produced no members"
    case propertyAlreadyExists = "Generated property already exists"
    case redundantApplication = "This macro application may be redundant"

    public var message: String { rawValue }

    public var diagnosticID: MessageID {
        MessageID(domain: "SwiftMacrosKit", id: rawValue)
    }

    public var severity: DiagnosticSeverity { .warning }
}
