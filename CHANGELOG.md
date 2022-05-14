## 0.6.0-dev.3

- Add tests for CustomText.selectable.
- Suppress warnings in Flutter 3.
- Minor refactoring.
- Update lint rules.
- Update and improve the example app.
- Improve documentation.

## 0.6.0-dev.2

- Fix issue of persistent hover style.
- Update text_parser to 0.3.3.
- Minor improvements.

## 0.6.0-dev.1

- Bug fixes and major refactors. (eb0e6f7, 760cb45, #12, #15)
- New features (experimental)
    - Add `CustomText.selectable`. (#16)
    - Add `CustomTextEditingController`. (#17)
- Depend on meta.
- Require Flutter >=2.8.0.

## 0.5.1

- Minor improvements.

## 0.5.0

- Fix an issue of tap and hover inactive in a rare condition. (#7)
- Fix issues of `setState()` called after `dispose()`. (#8, #10)
- Remove deprecated `onLongTap`.
- Minor refactoring.
- Improve documentation of definition classes.

## 0.4.0

- Add `ParserOptions` for tweaking RegExp settings.
- Add `parserOptions` parameter to `CustomText`.
- Add `LinkMatcher`.
- Depend on `text_parser` >=0.2.0.

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
