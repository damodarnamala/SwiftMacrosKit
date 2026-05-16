// NetworkingTests.swift
// SwiftMacrosKit — Networking Macro Tests

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(SwiftMacrosKitMacros)
@testable import SwiftMacrosKitMacros

let networkingMacros: [String: Macro.Type] = [
    "Endpoint": EndpointMacro.self,
    "GET": GETMacro.self,
    "POST": POSTMacro.self,
    "Headers": HeadersMacro.self,
    "Bearer": BearerMacro.self,
    "Multipart": MultipartMacro.self,
    "MockResponse": MockResponseMacro.self,
    "QueryParam": QueryParamMacro.self,
]

// MARK: - GET Tests

final class GETTests: XCTestCase {
    func testGETOnStruct() throws {
        assertMacroExpansion(
            """
            @GET("/users")
            struct UsersEndpoint {
            }
            """,
            expandedSource: """
            struct UsersEndpoint {

                func asURLRequest(baseURL: URL) -> URLRequest {
                    var request = URLRequest(url: baseURL.appendingPathComponent("/users"))
                    request.httpMethod = "GET"
                    return request
                }
            }
            """,
            macros: networkingMacros
        )
    }

    func testGETOnClassEmitsError() throws {
        assertMacroExpansion(
            """
            @GET("/users")
            class UsersEndpoint {
            }
            """,
            expandedSource: """
            class UsersEndpoint {
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: MacroError.requiresStruct.message, line: 1, column: 1)
            ],
            macros: networkingMacros
        )
    }

    func testGETDefaultPath() throws {
        assertMacroExpansion(
            """
            @GET
            struct RootEndpoint {
            }
            """,
            expandedSource: """
            struct RootEndpoint {

                func asURLRequest(baseURL: URL) -> URLRequest {
                    var request = URLRequest(url: baseURL.appendingPathComponent("/"))
                    request.httpMethod = "GET"
                    return request
                }
            }
            """,
            macros: networkingMacros
        )
    }
}

// MARK: - POST Tests

final class POSTTests: XCTestCase {
    func testPOSTOnStruct() throws {
        assertMacroExpansion(
            """
            @POST("/users")
            struct CreateUser {
            }
            """,
            expandedSource: """
            struct CreateUser {

                func asURLRequest(baseURL: URL) -> URLRequest {
                    var request = URLRequest(url: baseURL.appendingPathComponent("/users"))
                    request.httpMethod = "POST"
                    if let body = try? JSONEncoder().encode(self) {
                        request.httpBody = body
                        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    }
                    return request
                }
            }
            """,
            macros: networkingMacros
        )
    }

    func testPOSTOnClassEmitsError() throws {
        assertMacroExpansion(
            """
            @POST("/users")
            class CreateUser {
            }
            """,
            expandedSource: """
            class CreateUser {
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: MacroError.requiresStruct.message, line: 1, column: 1)
            ],
            macros: networkingMacros
        )
    }
}

// MARK: - Bearer Tests

final class BearerTests: XCTestCase {
    func testBearerOnStruct() throws {
        assertMacroExpansion(
            """
            @Bearer
            struct APIClient {
            }
            """,
            expandedSource: """
            struct APIClient {

                func applyBearerToken(to request: inout URLRequest, token: String) {
                    request.setValue("Bearer \\(token)", forHTTPHeaderField: "Authorization")
                }
            }
            """,
            macros: networkingMacros
        )
    }

    func testBearerOnClassEmitsError() throws {
        assertMacroExpansion(
            """
            @Bearer
            class APIClient {
            }
            """,
            expandedSource: """
            class APIClient {
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: MacroError.requiresStruct.message, line: 1, column: 1)
            ],
            macros: networkingMacros
        )
    }
}

// MARK: - MockResponse Tests

final class MockResponseTests: XCTestCase {
    func testMockResponseOnStruct() throws {
        assertMacroExpansion(
            """
            @MockResponse(json: "{\\"id\\": 1}", statusCode: 200)
            struct UserResponse {
            }
            """,
            expandedSource: """
            struct UserResponse {

                static func mockData() -> (Data, HTTPURLResponse) {
                    let data = "{\\"id\\": 1}".data(using: .utf8)!
                    let response = HTTPURLResponse(
                        url: URL(string: "https://mock.test")!,
                        statusCode: 200,
                        httpVersion: nil,
                        headerFields: nil
                    )!
                    return (data, response)
                }
            }
            """,
            macros: networkingMacros
        )
    }

    func testMockResponseOnClassEmitsError() throws {
        assertMacroExpansion(
            """
            @MockResponse(json: "{}", statusCode: 200)
            class UserResponse {
            }
            """,
            expandedSource: """
            class UserResponse {
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: MacroError.requiresStruct.message, line: 1, column: 1)
            ],
            macros: networkingMacros
        )
    }
}

// MARK: - QueryParam Tests

final class QueryParamTests: XCTestCase {
    func testQueryParamIsMarker() throws {
        assertMacroExpansion(
            """
            @QueryParam var page: Int = 1
            """,
            expandedSource: """
            var page: Int = 1
            """,
            macros: networkingMacros
        )
    }
}

#endif
