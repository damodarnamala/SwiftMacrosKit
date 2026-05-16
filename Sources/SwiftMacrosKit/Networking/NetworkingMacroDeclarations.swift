// NetworkingMacroDeclarations.swift
// SwiftMacrosKit — Networking Macro Declarations
// Category: [E] Networking
// Author: SwiftMacrosKit Contributors

/// Generates a URLRequest builder from struct properties.
///
/// - Parameters:
///   - path: The URL path.
///   - method: The HTTP method (e.g., "GET", "POST").
///
/// **Usage:** `@Endpoint(path: "/users", method: "GET") struct FetchUsers { ... }`
@attached(member, names: named(asURLRequest))
public macro Endpoint(path: String, method: String) = #externalMacro(module: "SwiftMacrosKitMacros", type: "EndpointMacro")

/// Shorthand for @Endpoint with GET method.
///
/// - Parameter path: The URL path.
///
/// **Usage:** `@GET("/users") struct FetchUsers { ... }`
@attached(member, names: named(asURLRequest))
public macro GET(_ path: String) = #externalMacro(module: "SwiftMacrosKitMacros", type: "GETMacro")

/// Shorthand for @Endpoint with POST method.
///
/// - Parameter path: The URL path.
///
/// **Usage:** `@POST("/users") struct CreateUser { ... }`
@attached(member, names: named(asURLRequest))
public macro POST(_ path: String) = #externalMacro(module: "SwiftMacrosKitMacros", type: "POSTMacro")

/// Merges provided headers into a generated URLRequest.
///
/// - Parameter headers: Dictionary of header key-value pairs.
///
/// **Usage:** `@Headers(["Accept": "application/json"]) struct Request { ... }`
@attached(member, names: named(applyHeaders))
public macro Headers(_ headers: [String: String]) = #externalMacro(module: "SwiftMacrosKitMacros", type: "HeadersMacro")

/// Marks a property to be encoded as a URL query parameter.
///
/// **Usage:** `@QueryParam var page: Int = 1`
@attached(accessor)
@attached(peer, names: prefixed(_))
public macro QueryParam() = #externalMacro(module: "SwiftMacrosKitMacros", type: "QueryParamMacro")

/// Injects an Authorization Bearer header from a token provider.
///
/// **Usage:** `@Bearer struct AuthenticatedRequest { ... }`
@attached(member, names: named(applyBearerToken))
public macro Bearer() = #externalMacro(module: "SwiftMacrosKitMacros", type: "BearerMacro")

/// Generates multipart/form-data encoded URLRequest.
///
/// **Usage:** `@Multipart struct UploadRequest { var file: Data; var name: String }`
@attached(member, names: named(asMultipartRequest))
public macro Multipart() = #externalMacro(module: "SwiftMacrosKitMacros", type: "MultipartMacro")

/// Generates a URLSession mock that returns provided JSON.
///
/// - Parameters:
///   - json: The JSON string to return.
///   - statusCode: The HTTP status code (default: 200).
///
/// **Usage:** `@MockResponse(json: "{\"ok\":true}", statusCode: 200) struct TestEndpoint { ... }`
@attached(member, names: named(mockData))
public macro MockResponse(json: String, statusCode: Int = 200) = #externalMacro(module: "SwiftMacrosKitMacros", type: "MockResponseMacro")
