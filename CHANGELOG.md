## 2.0.4

- Rerun SpanBuilder and CustomSpanBuilder on hot reload.
- Add advanced examples.

## 2.0.3

- Update dependencies.

## 2.0.2

- Fix wrong handling of styles in CustomTextEditingController. ([#61])
    - The cursor didn't respect the text height.
    - The style specified in editable text was ignored if another style was passed to the controller.
    - Changes in the style specified in editable text were not applied quickly.

## 2.0.1

- Fix bug where `SystemMouseCursors.click` was not used for clickable `WidgetSpan`. ([#54])
- Fix bugs related to `preBuilder`.
    - Match patterns were used for original text instead of `TextSpan` built by `preBuilder`. ([#55])
    - Update of `DefaultTextStyle` caused a rebuild and reset prebuilt `TextSpan`. ([#57])
    - Text elements were lost when both parsing and building were skipped in `preBuilder`. ([#59])
- Improve documentation to clarify the target of match patterns used in the context of `preBuilder`.
- Small refactoring.

## 2.0.0

- **Breaking:**
    - Raise minimum Flutter SDK version to 3.2.0. ([#47])
    - Remove deprecated `textScaleFactor` from `CustomText`and add `textScaler`. ([#47])
    - Change `shownText` and `actionText` of `SeletiveDefinition` and `builder`
      of `SpanDefinition` to receive a `TextElement` object. ([#46])
      - e.g. 
        ```dart
        // <2.0.0
        SelectiveDefinition(
          matcher: const LinkMatcher(),
          shownText: (groups) => groups[0]!,
          actionText: (groups) => groups[1]!,
        )
        ```
        ```dart        
        // >=2.0.0
        SelectiveDefinition(
          matcher: const LinkMatcher(),
          shownText: (element) => element.groups[0]!,
          actionText: (element) => element.groups[1]!,
        )
        ```
- Potentially breaking:
    - Change `Definition` to a sealed class.
- Small refactorings.
- Collapse the details of each example in README.

## 1.4.4

- Fix the bugs where changes in configurations were not fully reflected in the following cases. ([#51])
    - When both definitions and other configurations were updated.
    - When `DefaultTextStyle` changed while there were no other changes.

## 1.4.3

- Fix exception thrown when CustomText is removed before parsing completes. ([#49])

## 1.4.2

- Add notes about gesture-related parameters to README and examples of `CustomSpan.spans` and `preBuilder`.
- Add a note about `decorationColor` in Material 3 to README.
- Improve documents of properties of `CustomText`.

## 1.4.1

*Retracted due to breaking changes included unintentionally.* 

- Add notes about gesture-related parameters to README and examples of `CustomSpan.spans` and `preBuilder`.
- Add a note about `decorationColor` in Material 3 to README.
- Improve documents of properties of `CustomText`.

## 1.4.0

- Add `preBuilder` to `CustomText`. ([#44])
- Add `rebuildKey` to definitions. ([#45])
- Add missing `selectionColor` to CustomText.  
- Avoid rebuilding irrelevant spans when definitions are updated. ([#43])
- Bump text_parser version to 2.3.0.
- Refactorings.
- Improve documentation.

## 1.3.1

- Fix a potential issue where text was not shown quickly if it was given later than initial build.
- Extract span builder as a single class for a feature being planned for a future version.
- Improve span builder to apply gesture callbacks only when necessary.
- Improve handling of DefaultTextStyle.
- Other refactorings.
- Bump text_parser version to 2.2.1.
    - Matchers with empty RegExp pattern are now allowed. 

## 1.3.0

- Add the [CustomText.spans] constructor. ([#36])
    - This is useful if you already have styled spans and want to apply additional decoration.
- Deprecate `textScaleFactor`. ([#38])
    - `textScaler` will be added at a future major version.
- Bump text_parser version to 2.1.1.

## 1.2.1

- Fix a potential bug that could cause an empty span in edge case.
- Fix bugs of `CustomTextEditingController`.
    - Text style specified in controller was not used during initial parsing.
    - Text style specified in editable text was not used depending on the timing.
- Add an example of how to make real hyperlinks for the web.

## 1.2.0

- Refactor and improve handling of gestures.
    - Behaviours triggered by gestures is now more stable and natural.
        - e.g. Text style is no longer lost for an instant on tap when hoverStyle
          is specified and tapStyle is not.
- Add parameters to `SpanDefinition` to be equivalent to other definitions. ([#34])
    - Text style, mouse cursor type and gesture handlers are applied to the
      `InlineSpan` and its children created by the `builder` function.
    - Text style is also provided to `WidgetSpan`s via `DefaultTextStyle`.
- Make text invisible during initial parsing. ([#37])
    - It should be only a tiny moment, so won't have an impact.
    - This does not affect the cases where `preventBlocking` is enabled or only
      `TextDefinition`s are used.
- Improve documentation.

## 1.1.0

- Bump text_parser to 2.1.0.
- Support definitions with a matcher of the same type. ([#31])

## 1.0.0

- Bump text_parser to 2.0.0.
    - Contains a **breaking change** in `UrlMatcher`.
        - `UrlMatcher` no longer matches URLs not starting with http(s).
        - Use the new `UrlLikeMatcher` instead if necessary.
- Add support for using an external parser.
- Add typedef for gesture callbacks.
- Improve tests, documentation and example app.
- Update the note about using lookbehind assertions on Safari.

## 1.0.0-dev.2

- Bump text_parser to 1.2.0-dev.2.
    - Contains a **breaking change** in `UrlMatcher`.
        - `UrlMatcher` no longer matches URLs not starting with http(s).
        - Use the new `UrlLikeMatcher` instead if necessary.
- Update the example app.
- Update the note about using lookbehind assertions on Safari.

## 1.0.0-dev.1

- Add support for using an external parser.
- Add typedef for gesture callbacks.
- Bump text_parser to 1.2.0-dev.1.
    - No workaround is necessary any more to use lookbehind assertions.
- Add and improve tests.
- Improve documentation.

## 0.8.0

- **Breaking**:
    - Raise minimum Flutter SDK version to 3.7.0.
    - Remove `CustomText.selectable` that had been deprecated since 0.6.0. ([#24])
    - Handler functions now get `GestureDetails` object instead of matcher type and text. ([#25])
        - This is for supporting wider use cases.
          ```dart
          onTap: (details) {
            print(details.element.matcherType);
            print(details.actionText);
          
            // or more
            print(details.shownText);
            print(details.gestureKind);
            print(details.globalPosition);
            ...
          }
          ```
          instead of
          ```dart
          onTap: (type, text) {
            print(type);
            print(text);
          }
          ```
    - Integrate `CustomTextEditingController` into `custom_text.dart`.
        - Use
          ```dart
          import 'package:custom_text/custom_text.dart';
          ``` 
          instead of
          ```dart
          import 'package:custom_text/custom_text_editing_controller.dart';
          ``` 
- New:
    - Add `onGesture`. ([#27])
        - This handler supports secondary and tertiary buttons and mouse enter and exit events.
- Expose the base definition class.
- Expose the typedefs of builders of `SelectiveDefinition` and `SpanDefinition`. 
- Internal refactorings.

## 0.7.0

- Raise minimum Flutter SDK version to 3.3.0.
- Refactor `TextSpanNotifier` to make it easier to add features in future versions.
- Remove an inappropriate condition from didUpdateWidget.
- Add screenshots to pubspec.yaml.

## 0.6.1

- Fix `Definition` and `ParserOptions` to use also `runtimeType` for `hashCode` calculation.
- Remove override of `toString()` from `ParserOptions`.
- Make sure that null is not passed to the following parameters:
    - `labelSelector` of SelectiveDefinition
    - `builder` of SpanDefinition
- Use text_parser 0.4.2.
- Update example app.

## 0.6.0

- New:
    - Add `CustomText.selectable`. ([#16])
        - Deprecated. ([#19])
        - Will be removed in the future in favour of `SelectionArea`.
    - Add `CustomTextEditingController`. ([#17], [#20])
- Maybe breaking:
    - Use `hoverStyle` while being pressed if `tapStyle` is not provided.
- Many bug fixes, improvements and major refactors. ([eb0e6f7], [760cb45], [#12], [#15], etc)
    - Please see the history of dev versions for details. 
- Require Flutter >=3.0.0.
- Bump text_parser to 0.4.1.
- Depend on meta.
- Update dependencies.

## 0.6.0-dev.6

- Bump text_parser to 0.4.0.
- Fix issue where changes of some properties were not reflected. ([#22])

## 0.6.0-dev.5

- Maybe breaking:
    - Use `hoverStyle` while being pressed if `tapStyle` is not provided.
- Suppress error caused by updates of value after dispose().
- Add test for behaviour on hover without `hoverStyle`.
- Improve documentation, example app, etc.

## 0.6.0-dev.4

- Require Flutter >=3.0.0.
- Deprecate:
    - `CustomText.selectable` constructor is now deprecated. ([#19])
        - Use SelectionArea on Flutter 3.3 and above.
        - If SelectionArea is insufficient, use CustomTextEditingController and TextField with `readOnly: true`.
- New (experimental):
    - Add `debounceDuration` to `CustomTextEditingController` for somewhat better performance with long text. ([#20])
- Fix behaviour of `CustomTextEditingController` when text spans are rebuilt while one of them is hovered/pressed on.
- Discard gesture recognizers more thoroughly.
- Add tests for `CustomTextEditingController`.
- Minor refactoring.

## 0.6.0-dev.3

- Add tests for `CustomText.selectable`.
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

- Bug fixes and major refactors. ([eb0e6f7], [760cb45], [#12], [#15])
- New (experimental):
    - Add `CustomText.selectable`. ([#16])
    - Add `CustomTextEditingController`. ([#17])
- Depend on meta.
- Require Flutter >=2.8.0.

## 0.5.1

- Bump text_parser to 0.3.2.
- Minor improvements.

## 0.5.0

- Fix an issue of tap and hover inactive in a rare condition. ([#7])
- Fix issues of `setState()` called after `dispose()`. ([#8], [#10])
- Remove deprecated `onLongTap`.
- Minor refactoring.
- Improve documentation of definition classes.

## 0.4.0

- New:
    - Add `ParserOptions` for tweaking RegExp settings.
    - Add `parserOptions` parameter to `CustomText`.
    - Add `LinkMatcher`.
- Depend on text_parser >=0.2.0.

## 0.3.1

- Fix to allow dynamic update of text.

## 0.3.0

- **Breaking change**:
    - Use the `mouseCursor` property of `TextSpan` for changing the mouse cursor. ([#4])
        - `cursorOnHover`, which was experimental, was removed from `CustomText`.
        - `mouseCursor` was added to `TextDefinition` and `SelectiveDefinition`.
- Deprecate:
    - `onLongTap` is now deprecated; use `onLongPress` instead.
- New:
    - Add `hoverStyle` to `CustomText`, `TextDefinition` and `SelectiveDefinition`.
- Refactoring and enhancement:
    - Improve management of tap state.
    - Prevent unnecessary rebuilds and duplicate recognizer creations.
    - Update example project.

## 0.2.0

- Fix the error of undefined `SystemMouseCursor` on Flutter 2.2. ([#2])
    - Requires Flutter >=2.2.0.
- Several minor changes.

## 0.1.2

- Fix and improve documentation.

## 0.1.1

- Fix to properly dispose of `TapGestureRecognizer`.
- Remove note on web limitations.
- Refactoring and some improvements.
- New (experimental):
    - Add feature to change mouse cursor on hover over clickable element.

## 0.1.0

- Bump text_parser to 0.1.2.
- Migrate to null safety.

## 0.0.3

- Add tests.
- Bump text_parser to 0.0.5.
- Change minimum Dart SDK version to 2.8.1 to match text_parser.
- Workaround for Flutter issue.
- Improve documentation and examples.

## 0.0.2

- Fix broken links in README files.

## 0.0.1

- Initial version.

[CustomText.spans]: https://pub.dev/documentation/custom_text/latest/custom_text/CustomText/CustomText.spans.html
[#2]: https://github.com/kaboc/flutter_custom_text/pull/2
[#4]: https://github.com/kaboc/flutter_custom_text/pull/4
[#7]: https://github.com/kaboc/flutter_custom_text/pull/7
[#8]: https://github.com/kaboc/flutter_custom_text/pull/8
[#10]: https://github.com/kaboc/flutter_custom_text/pull/10
[eb0e6f7]: https://github.com/kaboc/flutter_custom_text/commit/eb0e6f7013941141ba196fc1144e81bc36dfe5fe
[760cb45]: https://github.com/kaboc/flutter_custom_text/commit/760cb4501f6126de2b25f5086e202e427dc33b4d
[#12]: https://github.com/kaboc/flutter_custom_text/pull/12
[#15]: https://github.com/kaboc/flutter_custom_text/pull/15
[#16]: https://github.com/kaboc/flutter_custom_text/pull/16
[#17]: https://github.com/kaboc/flutter_custom_text/pull/17
[#19]: https://github.com/kaboc/flutter_custom_text/pull/19
[#20]: https://github.com/kaboc/flutter_custom_text/pull/20
[#22]: https://github.com/kaboc/flutter_custom_text/pull/22
[#24]: https://github.com/kaboc/flutter_custom_text/pull/24
[#25]: https://github.com/kaboc/flutter_custom_text/pull/25
[#27]: https://github.com/kaboc/flutter_custom_text/pull/27
[#31]: https://github.com/kaboc/flutter_custom_text/pull/31
[#34]: https://github.com/kaboc/flutter_custom_text/pull/34
[#36]: https://github.com/kaboc/flutter_custom_text/pull/36
[#37]: https://github.com/kaboc/flutter_custom_text/pull/37
[#38]: https://github.com/kaboc/flutter_custom_text/pull/38
[#43]: https://github.com/kaboc/flutter_custom_text/pull/43
[#44]: https://github.com/kaboc/flutter_custom_text/pull/44
[#45]: https://github.com/kaboc/flutter_custom_text/pull/45
[#46]: https://github.com/kaboc/flutter_custom_text/pull/46
[#47]: https://github.com/kaboc/flutter_custom_text/pull/47
[#49]: https://github.com/kaboc/flutter_custom_text/pull/49
[#51]: https://github.com/kaboc/flutter_custom_text/pull/51
[#54]: https://github.com/kaboc/flutter_custom_text/pull/54
[#55]: https://github.com/kaboc/flutter_custom_text/pull/55
[#57]: https://github.com/kaboc/flutter_custom_text/pull/57
[#59]: https://github.com/kaboc/flutter_custom_text/pull/59
[#61]: https://github.com/kaboc/flutter_custom_text/pull/61
