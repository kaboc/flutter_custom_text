import 'package:flutter/material.dart';

import 'package:custom_text/custom_text.dart';
import 'package:positioned_popup/positioned_popup.dart';

export 'package:positioned_popup/positioned_popup.dart';

extension ShowPopup on PopupController {
  void show(BuildContext context, GestureDetails details) {
    PopupArea.of(context).open(
      controller: this,
      popupKey: ValueKey(details.shownText),
      position: details.globalPosition,
      maxWidth: 260.0,
      barrierDismissible: false,
      autoCloseWait: const Duration(milliseconds: 200),
      child: GestureDetector(
        onTap: close,
        child: Card(
          elevation: 4.0,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12.0),
            child: CustomText(
              _kPopupMessages[details.shownText] ?? '',
              definitions: [
                SelectiveDefinition(
                  matcher: const PatternMatcher(r'\*\*(.+?)\*\*'),
                  shownText: (groups) => groups.first!,
                ),
              ],
              style: const TextStyle(fontSize: 14.0),
              matchStyle: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  void toggle(BuildContext context, GestureDetails details) {
    if (popupKey == ValueKey(details.shownText)) {
      close();
    } else {
      show(context, details);
    }
  }
}

const _kPopupMessages = {
  'open-source': '**Open-source software (OSS)** is computer software that '
      'is released under a license in which the copyright holder grants users '
      'the rights to use, study, change, and distribute the software and its '
      'source code to anyone and for any purpose.',
  'UI': 'In the industrial design field of human–computer interaction, a '
      '**user interface (UI)** is the space where interactions between humans '
      'and machines occur. The goal of this interaction is to allow effective '
      'operation and control of the machine from the human end.',
  'software development kit': 'A **software development kit (SDK)** is a '
      'collection of software development tools in one installable package. '
      'They facilitate the creation of applications by having a compiler, '
      'debugger and sometimes a software framework.',
  'Google': '**Google LLC** is an American multinational technology company '
      'focusing on online advertising, search engine technology, cloud '
      'computing, computer software, quantum computing, e-commerce, '
      'artificial intelligence, and consumer electronics.',
  'cross-platform applications': 'In computing, **cross-platform software** '
      '(also called **multi-platform software**, **platform-agnostic '
      'software**, or **platform-independent software**) is computer software '
      'that is designed to work in several computing platforms.',
  'Android': '**Android** is a mobile operating system based on a modified '
      'version of the Linux kernel and other open-source software, designed '
      'primarily for touchscreen mobile devices such as smartphones and '
      'tablets.',
  'iOS': '**iOS** (formerly iPhone OS) is a mobile operating system developed '
      'by Apple Inc. exclusively for its hardware. It is the operating system '
      "that powers many of the company's mobile devices.",
  'Linux': '**Linux** is a family of open-source Unix-like operating systems '
      'based on the Linux kernel, an operating system kernel first released '
      'on September 17, 1991, by Linus Torvalds.',
  'macOS': '**macOS** is a Unix operating system developed and marketed by '
      "Apple Inc. since 2001. It is the primary operating system for Apple's "
      'Mac computers.',
  'Windows': '**Windows** is a group of several proprietary graphical '
      'operating system families developed and marketed by Microsoft. Each '
      'family caters to a certain sector of the computing industry.',
  'Google Fuchsia': '**Fuchsia** is an open-source capability-based operating '
      "system developed by Google. In contrast to Google's Linux-based "
      'operating systems such as ChromeOS and Android, Fuchsia is based on '
      'a custom kernel named Zircon.',
  'web': 'The **Web platform** is a collection of technologies developed as '
      'open standards by the World Wide Web Consortium and other '
      'standardization bodies such as the Web Hypertext Application '
      'Technology Working Group, the Unicode Consortium,',
  'codebase': 'In software development, a **codebase** (or **code base**) '
      'is a collection of source code used to build a particular software '
      'system, application, or software component.',
};
