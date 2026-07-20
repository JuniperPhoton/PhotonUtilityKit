# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

PhotonUtilityKit is a Swift Package of shared utilities and SwiftUI components used across the author's apps (MyerList, MyerTidy, MyerSplash, Photon AI Translator). It supports iOS 16+, macOS 13+, watchOS 9+ and tvOS 16+, with no external dependencies.

## Commands

```bash
# Build the package
swift build

# Run all tests
swift test

# Run a single test class / method
swift test --filter OSTypeTests
swift test --filter PhotonUtilityKitTests.OSTypeTests/testMethodName
```

Building requires a full Xcode toolchain — the Command Line Tools toolchain fails to expand SwiftUI macros like `@Entry` (used in `PhotonUtilityView`). If `xcode-select -p` points at `/Library/Developer/CommandLineTools`, prefix commands with `DEVELOPER_DIR=/Applications/Xcode-26.6.0.app/Contents/Developer` (or whichever Xcode is installed).

The demo app lives in `PhotonUtilityKitDemo/` (an Xcode project referenced by `PhotonUtilityKit.xcworkspace`). Build it with Xcode or:

```bash
xcodebuild -workspace PhotonUtilityKit.xcworkspace -scheme PhotonUtilityKitDemo -destination 'platform=macOS' build
```

## Architecture

Three targets, exposed together through three products that differ only in linkage (`PhotonUtilityKit` = automatic, `-Static`, `-Dynamic`):

- **PhotonUtility** — the foundation layer: extensions, app services (pasteboard, orientation, keyboard observer, window/screenshot services), file IO, logging, and availability-gated compat wrappers in `Compat/`. No dependency on the other targets.
- **PhotonUtilityView** — SwiftUI components (Toast, FullscreenPresentation, AppSegmentTabBar, BottomSheet, page views, etc.). Depends on `PhotonUtility` and `PhotonLegacyCompat`.
- **PhotonLegacyCompat** — standalone compatibility layer for OS 26 Liquid Glass APIs (`liquidGlassIfAvailable`, glass button/container/toolbar helpers) with fallbacks for older OS versions.

Tests (`Tests/PhotonUtilityKitTests`) only cover `PhotonUtility`.

## Conventions

- Multiplatform code is the norm: most files compile for all four platforms, using `#if canImport(UIKit)` / `#if canImport(AppKit)` and `#if os(...)` guards. When touching shared code, keep it building on iOS, macOS, watchOS and tvOS — watchOS and tvOS are the ones most easily broken (see recent fix commits).
- New-API adoption goes through compat wrappers (`Sources/PhotonUtility/Compat/`, `PhotonLegacyCompat`) that check `#available` and provide fallbacks, rather than raising the package's minimum deployment targets.
- Public APIs are documented with `///` doc comments, often with usage examples in an `# Overview` section.
