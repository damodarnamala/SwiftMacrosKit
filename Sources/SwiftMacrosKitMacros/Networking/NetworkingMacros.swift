// NetworkingMacros.swift
// SwiftMacrosKit — Networking Macro Implementations
// Category: [E] Networking
// Author: SwiftMacrosKit Contributors

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

// MARK: - EndpointMacro

public struct EndpointMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard declaration.isStruct else {
            context.addDiagnostic(.requiresStruct, at: node)
            return []
        }

        let args = node.labeledArguments
        let path = args.first(where: { $0.label == "path" })?.expression.trimmedDescription ?? "\"/\""
        let method = args.first(where: { $0.label == "method" })?.expression.trimmedDescription ?? "\"GET\""

        let properties = declaration.storedProperties
        var queryItems = [String]()
        for prop in properties {
            guard let name = prop.propertyName else { continue }
            queryItems.append("""
                URLQueryItem(name: "\(name)", value: "\\(self.\(name))")
            """)
        }
        let queryStr = queryItems.joined(separator: ",\n            ")

        return ["""
        func asURLRequest(baseURL: URL) -> URLRequest {
            var components = URLComponents(url: baseURL.appendingPathComponent(\(raw: path)), resolvingAgainstBaseURL: false)!
            components.queryItems = [
                \(raw: queryStr)
            ]
            var request = URLRequest(url: components.url!)
            request.httpMethod = \(raw: method)
            return request
        }
        """]
    }
}

// MARK: - GETMacro

public struct GETMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard declaration.isStruct else {
            context.addDiagnostic(.requiresStruct, at: node)
            return []
        }

        let path = node.stringArguments.first ?? "/"

        return ["""
        func asURLRequest(baseURL: URL) -> URLRequest {
            var request = URLRequest(url: baseURL.appendingPathComponent(\(literal: path)))
            request.httpMethod = "GET"
            return request
        }
        """]
    }
}

// MARK: - POSTMacro

public struct POSTMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard declaration.isStruct else {
            context.addDiagnostic(.requiresStruct, at: node)
            return []
        }

        let path = node.stringArguments.first ?? "/"

        return ["""
        func asURLRequest(baseURL: URL) -> URLRequest {
            var request = URLRequest(url: baseURL.appendingPathComponent(\(literal: path)))
            request.httpMethod = "POST"
            if let body = try? JSONEncoder().encode(self) {
                request.httpBody = body
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
            return request
        }
        """]
    }
}

// MARK: - HeadersMacro

public struct HeadersMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard declaration.isStruct else {
            context.addDiagnostic(.requiresStruct, at: node)
            return []
        }

        guard let dictExpr = node.labeledArguments.first?.expression else {
            context.addDiagnostic(.missingArguments, at: node)
            return []
        }

        return ["""
        func applyHeaders(to request: inout URLRequest) {
            let headers: [String: String] = \(dictExpr)
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        """]
    }
}

// MARK: - QueryParamMacro

public struct QueryParamMacro: AccessorMacro, PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        guard let varDecl = declaration.as(VariableDeclSyntax.self),
              let name = varDecl.propertyName else {
            return []
        }
        let getter: AccessorDeclSyntax = "get { _\(raw: name) }"
        let setter: AccessorDeclSyntax = """
        set {
            _\(raw: name) = newValue
        }
        """
        return [getter, setter]
    }

    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let varDecl = declaration.as(VariableDeclSyntax.self),
              let name = varDecl.propertyName,
              let type = varDecl.propertyTypeName else {
            return []
        }
        if let initialValue = varDecl.initialValue {
            return ["var _\(raw: name): \(raw: type) = \(initialValue)"]
        }
        return ["var _\(raw: name): \(raw: type)"]
    }
}

// MARK: - BearerMacro

public struct BearerMacro: MemberMacro {
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
        func applyBearerToken(to request: inout URLRequest, token: String) {
            request.setValue("Bearer \\(token)", forHTTPHeaderField: "Authorization")
        }
        """]
    }
}

// MARK: - MultipartMacro

public struct MultipartMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard declaration.isStruct else {
            context.addDiagnostic(.requiresStruct, at: node)
            return []
        }

        let properties = declaration.storedProperties
        var parts = [String]()
        for prop in properties {
            guard let name = prop.propertyName else { continue }
            parts.append("""
                body.append("--\\(boundary)\\r\\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\\"\(name)\\"\\r\\n\\r\\n".data(using: .utf8)!)
                body.append("\\(self.\(name))\\r\\n".data(using: .utf8)!)
            """)
        }

        let partsStr = parts.joined(separator: "\n        ")

        return ["""
        func asMultipartRequest(baseURL: URL, path: String) -> URLRequest {
            let boundary = UUID().uuidString
            var request = URLRequest(url: baseURL.appendingPathComponent(path))
            request.httpMethod = "POST"
            request.setValue("multipart/form-data; boundary=\\(boundary)", forHTTPHeaderField: "Content-Type")
            var body = Data()
            \(raw: partsStr)
            body.append("--\\(boundary)--\\r\\n".data(using: .utf8)!)
            request.httpBody = body
            return request
        }
        """]
    }
}

// MARK: - MockResponseMacro

public struct MockResponseMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard declaration.isStruct else {
            context.addDiagnostic(.requiresStruct, at: node)
            return []
        }

        let args = node.labeledArguments
        let json = args.first(where: { $0.label == "json" })?.expression.trimmedDescription ?? "\"{}\""
        let statusCode = args.first(where: { $0.label == "statusCode" })?.expression.trimmedDescription ?? "200"

        return ["""
        static func mockData() -> (Data, HTTPURLResponse) {
            let data = \(raw: json).data(using: .utf8)!
            let response = HTTPURLResponse(
                url: URL(string: "https://mock.test")!,
                statusCode: \(raw: statusCode),
                httpVersion: nil,
                headerFields: nil
            )!
            return (data, response)
        }
        """]
    }
}
