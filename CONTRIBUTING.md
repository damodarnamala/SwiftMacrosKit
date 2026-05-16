# Contributing to SwiftMacrosKit

Thank you for considering contributing to SwiftMacrosKit! This guide explains how to get started.

## Development Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/user/SwiftMacrosKit.git
   cd SwiftMacrosKit
   ```

2. **Build**
   ```bash
   swift build
   ```

3. **Run tests**
   ```bash
   swift test
   ```

## Project Structure

```
Sources/
  SwiftMacrosKit/              # Public macro declarations (@attached/@freestanding)
    Creational/
    Validation/
    ...
  SwiftMacrosKitMacros/        # Macro implementations (swift-syntax AST transforms)
    Shared/                    # Shared helpers (MacroError, SyntaxHelpers, DiagnosticHelpers)
    Creational/
    Validation/
    ...
Tests/
  SwiftMacrosKitTests/         # Tests using assertMacroExpansion
    CreationalTests/
    ValidationTests/
    ...
```

## Adding a New Macro

1. **Declare the macro** in `Sources/SwiftMacrosKit/<Category>/`:
   ```swift
   @attached(member, names: arbitrary)
   public macro MyMacro() = #externalMacro(module: "SwiftMacrosKitMacros", type: "MyMacroMacro")
   ```

2. **Implement the macro** in `Sources/SwiftMacrosKitMacros/<Category>/`:
   - Conform to the appropriate protocol (`MemberMacro`, `AccessorMacro`, `PeerMacro`, `ExpressionMacro`, or `DeclarationMacro`)
   - Use shared helpers from `Shared/` for diagnostics and syntax operations
   - Emit clear diagnostic errors for unsupported targets

3. **Register the macro** in `SwiftMacrosKitPlugin.swift`:
   ```swift
   providingMacros: [
       // ...existing macros...
       MyMacroMacro.self,
   ]
   ```

4. **Write tests** in `Tests/SwiftMacrosKitTests/<Category>Tests/`:
   - Minimum 3 tests per macro: valid expansion, invalid target, edge case
   - Use `assertMacroExpansion` from `SwiftSyntaxMacrosTestSupport`
   - Match SwiftSyntax's output formatting exactly (it may add spaces before parens, break closures to multiple lines, etc.)

5. **Verify**:
   ```bash
   swift build && swift test
   ```

## Coding Guidelines

- Follow existing code conventions and file organization
- Use `MacroError` diagnostics for user-facing errors
- Keep macro expansions minimal — generate only what's necessary
- Prefer `MemberMacro` for adding members to types, `AccessorMacro` for property wrappers, `PeerMacro` for companion declarations
- All public APIs must be in `Sources/SwiftMacrosKit/`, never in the macro plugin target

## Pull Requests

1. Fork the repository and create a feature branch
2. Ensure all tests pass (`swift test`)
3. Keep commits focused and descriptive
4. Open a PR against `main` with a clear description of changes

## Reporting Issues

Open a GitHub issue with:
- Swift version (`swift --version`)
- macOS version
- Minimal reproduction code
- Expected vs. actual behavior
