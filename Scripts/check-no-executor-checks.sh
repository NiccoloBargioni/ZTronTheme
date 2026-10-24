#!/bin/sh
# Verifies the "Swift 6 isolation" invariant documented in README.md: the ZTronTheme module
# contains no main-actor executor checks, so nothing in it can trap with
# `_dispatch_assert_queue_fail` / "unexpected executor" regardless of which thread SwiftUI
# runs it on.
#
# It compiles the module to whole-module SIL for the iOS simulator with `DEBUG` undefined
# (so the `#if DEBUG` previews are excluded, as in a release configuration), at both -Onone
# (every check the compiler emits is visible, nothing inlined or folded yet) and -O (what
# ships), and fails if any function body emitted for this module — including compiler
# generated thunks, which are named only after the types involved — calls one of the
# runtime checks. Bundle.module is stubbed because SwiftPM generates that accessor at
# build time. Expected output: "OK".
set -eu
cd "$(dirname "$0")/.."

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
cat > "$tmp/bundle_stub.swift" <<'STUB'
import Foundation
extension Foundation.Bundle { static let module: Bundle = Bundle.main }
STUB

pattern='swift_task_reportUnexpectedExecutor|swift_task_isCurrentExecutor|swift_task_checkIsolated|_checkExpectedExecutor|assumeIsolated|assertIsolated|preconditionIsolated'
status=0
for opt in -Onone -O; do
  find Sources -name '*.swift' -print0 | xargs -0 xcrun swiftc -emit-sil "$opt" -wmo \
    -target arm64-apple-ios15.0-simulator \
    -sdk "$(xcrun --sdk iphonesimulator --show-sdk-path)" \
    -swift-version 6 -module-name ZTronTheme \
    "$tmp/bundle_stub.swift" -o "$tmp/ZTronTheme$opt.sil"

  # A finding is a call site (`function_ref @...`) of one of the checks inside any function
  # body this compilation emitted. Bodies deserialized from other modules (`*_external`
  # linkage, e.g. the standard library's own helpers) are declarations here, not findings.
  offenders=$(awk -v pat="$pattern" '
    /^sil / { fn = $0; external = ($0 ~ /_external/) }
    /function_ref @/ && $0 ~ pat && !external { print fn }
  ' "$tmp/ZTronTheme$opt.sil" | sort -u | sed -E 's/^sil [^@]*@([^ ]+).*/\1/')
  if [ -n "$offenders" ]; then
    echo "FAIL ($opt): executor checks found in the non-DEBUG SIL of ZTronTheme:"
    printf '%s\n' "$offenders" | xargs -n1 xcrun swift-demangle -compact
    status=1
  fi
done
[ "$status" -eq 0 ] && echo "OK: no executor checks in the non-DEBUG SIL of ZTronTheme (-Onone and -O)"
exit "$status"
