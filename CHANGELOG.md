## 0.3.1

- Fix to allow dynamic update of text.

## 0.3.0

- **Breaking change**
    - Use the `mouseCursor` property of `TextSpan` for changing the mouse cursor. (#4)
        - `cursorOnHover`, which was experimental, was removed from `CustomText`.
        - `mouseCursor` was added to `TextDefinition` and `SelectiveDefinition`.
- Deprecated
    - `onLongTap` is now deprecated; use `onLongPress` instead.
- New feature
    - Add `hoverStyle` to `CustomText`, `TextDefinition` and `SelectiveDefinition`.
- Refactoring and enhancement
    - Improve management of tap state.
    - Prevent unnecessary rebuilds and duplicate recognizer creations.
    - Update example project.

## 0.2.0

- Fix the error of undefined `SystemMouseCursor` on Flutter 2.2. (#2)
    - Requires Flutter >=2.2.0.
- Several minor changes.

## 0.1.2

- Fix and improve documentation.

## 0.1.1

- Fix to properly dispose of `TapGestureRecognizer`.
- Remove note on web limitations.
- Refactoring and some improvements.
- Experimental
    - Add feature to change mouse cursor on hover over clickable element.

## 0.1.0

- Migrate to null safety.

## 0.0.3

- Add tests.
- Change minimum SDK version to match text_parser.
- Workaround for Flutter issue.
- Improve documentation and examples.

## 0.0.2

- Fix broken links in README files.

## 0.0.1

- Initial version.
