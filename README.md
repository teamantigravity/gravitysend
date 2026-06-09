# GravitySend

[![CI status][ci-badge]][ci-workflow]
[![Translations][translate-badge]][translate-link]
[![Packaging status][packaging-badge]][packaging-link]

[ci-badge]: https://github.com/GravitySend/GravitySend/actions/workflows/ci.yml/badge.svg
[ci-workflow]: https://github.com/GravitySend/GravitySend/actions/workflows/ci.yml
[translate-badge]: https://hosted.weblate.org/widget/GravitySend/app/svg-badge.svg
[translate-link]: https://hosted.weblate.org/engage/GravitySend/
[packaging-badge]: https://repology.org/badge/tiny-repos/GravitySend.svg
[packaging-link]: https://repology.org/project/GravitySend/versions

[Homepage][homepage] • [Discord][discord] • [GitHub][github] • [Codeberg][codeberg]

[English (Default)](README.md) • [Español](readme_i18n/README_ES.md) • [فارسی](readme_i18n/README_FA.md) • [Filipino](readme_i18n/README_PH.md) • [Français](readme_i18n/README_FR.md) • [Indonesia](readme_i18n/README_ID.md) • [Italiano](readme_i18n/README_IT.md) • [日本語](readme_i18n/README_JA.md) • [ភាសាខ្មែរ](readme_i18n/README_KM.md) • [한국어](readme_i18n/README_KO.md) • [Polski](readme_i18n/README_PL.md) • [Português Brasil](readme_i18n/README_PT_BR.md) • [Русский](readme_i18n/README_RU.md) • [ภาษาไทย](readme_i18n/README_TH.md) • [Türkçe](readme_i18n/README_TR.md) • [Українська](readme_i18n/README_UK.md) • [Tiếng Việt](readme_i18n/README_VI.md) • [中文](readme_i18n/README_ZH.md)

[homepage]: https://GravitySend.org
[discord]: https://discord.gg/GSRWmQNP87
[github]: https://github.com/GravitySend/GravitySend
[codeberg]: https://codeberg.org/GravitySend/GravitySend

GravitySend is a free, open-source app that allows you to securely share files and messages with nearby devices over your local network without needing an internet connection.

- [About](#about)
- [Sponsors](#sponsors)
- [Screenshots](#screenshots)
- [Download](#download)
- [How It Works](#how-it-works)
- [Getting Started](#getting-started)
- [Contributing](#contributing)
  - [Translation](#translation)
  - [Bug Fixes and Improvements](#bug-fixes-and-improvements)
- [Troubleshooting](#troubleshooting)
- [Building](#building)
  - [Android](#android)
  - [iOS](#ios)
  - [macOS](#macos)
  - [Windows](#windows)
  - [Linux](#linux)

## About

GravitySend is a cross-platform app that enables secure communication between devices using a REST API and HTTPS encryption. Unlike other messaging apps that rely on external servers, GravitySend doesn't require an internet connection or third-party servers, making it a fast and reliable solution for local communication.

## Sponsors

Browser testing via

<a href="https://www.testmuai.com/?utm_medium=sponsor&utm_source=GravitySend" target="_blank">
    <img src="https://GravitySend.org/img/sponsors/tesmu.svg" style="vertical-align: middle;" width="250" height="45" />
</a>

## Screenshots

<img src="https://GravitySend.org/img/screenshot-iphone.webp" alt="iPhone screenshot" height="300"/> <img src="https://GravitySend.org/img/screenshot-pc.webp" alt="PC screenshot" height="300"/>

## Download

[![Packaging status](https://repology.org/badge/tiny-repos/GravitySend.svg)](https://repology.org/project/GravitySend/versions)

It is recommended to download the app either from an app store or from a package manager because the app does not have an auto-update.

| Windows                 | macOS                   | Linux              | Android        | iOS           | Fire OS    |
|-------------------------|-------------------------|--------------------|----------------|---------------|------------|
| [Winget][]              | [App Store][]           | [Flathub][]        | [Play Store][] | [App Store][] | [Amazon][] |
| [Scoop][]               | [Homebrew][]            | [Nixpkgs][]        | [F-Droid][]    |               |            |
| [Chocolatey][]          | [DMG Installer][latest] | [Snap][]           | [APK][latest]  |               |            |
| [EXE Installer][latest] |                         | [AUR][]            |                |               |            |
| [Portable ZIP][latest]  |                         | [TAR][latest]      |                |               |            |
|                         |                         | [DEB][latest]      |                |               |            |
|                         |                         | [AppImage][latest] |                |               |            |

Read more about [distribution channels][].

> [!CAUTION]
> **Unofficial MSIX preview:** you can try builds from the latest commits at [GravitySend.ob-buff.dev](https://GravitySend.ob-buff.dev/). Stability is not guaranteed and all custom code tweaks are listed on that site.

[windows store]: https://www.microsoft.com/store/apps/9NCB4Z0TZ6RR
[app store]: https://apps.apple.com/us/app/GravitySend/id1661733229
[play store]: https://play.google.com/store/apps/details?id=org.GravitySend.GravitySend_app
[f-droid]: https://f-droid.org/packages/org.GravitySend.GravitySend_app
[amazon]: https://www.amazon.com/dp/B0BW6MP732
[winget]: https://github.com/microsoft/winget-pkgs/tree/master/manifests/l/GravitySend/GravitySend
[scoop]: https://scoop.sh/#/apps?s=0&d=1&o=true&q=GravitySend&id=fb88113be361ca32c0dcac423cb4afdeda0b0c66
[chocolatey]: https://community.chocolatey.org/packages/GravitySend
[homebrew]: https://formulae.brew.sh/cask/GravitySend
[flathub]: https://flathub.org/apps/details/org.GravitySend.GravitySend_app
[nixpkgs]: https://search.nixos.org/packages?show=GravitySend
[snap]: https://snapcraft.io/GravitySend
[aur]: https://aur.archlinux.org/packages/GravitySend-bin
[latest]: https://github.com/GravitySend/GravitySend/releases/latest
[distribution channels]: https://github.com/GravitySend/GravitySend/blob/main/CONTRIBUTING.md#distribution

**Compatibility**

| Platform | Minimum Version | Note                                                                                                                        |
|----------|-----------------|-----------------------------------------------------------------------------------------------------------------------------|
| Android  | 5.0             | -                                                                                                                           |
| iOS      | 12.0            | -                                                                                                                           |
| macOS    | 11 Big Sur      | Use OpenCore Legacy Patcher 2.0.2 (See [#1005](https://github.com/GravitySend/GravitySend/issues/1005#issuecomment-2449899384)) |
| Windows  | 10              | The last version to support Windows 7 is v1.15.4. There might be backports of newer versions for Windows 7 in the future.   |
| Linux    | N.A.            | Deps: Gnome: `xdg-desktop-portal` and `xdg-desktop-portal-gtk`, KDE: `xdg-desktop-portal` and `xdg-desktop-portal-kde`      |

## Setup

In most cases, GravitySend should work out of the box. However, if you are having trouble sending or receiving files, you may need to configure your firewall to allow GravitySend to communicate over your local network.

| Traffic Type | Protocol | Port  | Action |
|--------------|----------|-------|--------|
| Incoming     | TCP, UDP | 53317 | Allow  |
| Outgoing     | TCP, UDP | Any   | Allow  |

Also make sure to disable AP isolation on your router. It should be usually disabled by default but some routers may have it enabled (especially guest networks).
See [troubleshooting](#troubleshooting) for more information.

**Portable Mode**

(Introduced in v1.13.0)

Create a file named `settings.json` located in the same directory as the executable.
This file can be empty.
The app will use this file to store settings instead of the default location.

**Start hidden**

(Updated in v1.15.0)

To start the app hidden (only in tray), use the `--hidden` flag (example: `GravitySend_app.exe --hidden`).

On v1.14.0 and earlier, the app starts hidden if `autostart` flag is set, and the hidden setting is enabled.

## How It Works

GravitySend uses a secure communication protocol that allows devices to communicate with each other using a REST API. All data is sent securely over HTTPS, and the TLS/SSL certificate is generated on the fly on each device, ensuring maximum security.

For more information on the GravitySend Protocol, see the [documentation](https://github.com/GravitySend/protocol).

## Getting Started

To compile GravitySend from the source code, follow these steps:

1. Install Flutter [directly](https://flutter.dev) or using [fvm](https://fvm.app) (see [version required](.fvmrc))
2. Install [Rust](https://www.rust-lang.org/tools/install)
3. Clone the `GravitySend` repository
4. Run `cd app` to enter the app directory
5. Run `flutter pub get` to download dependencies
6. Run `flutter run` to start the app

> [!NOTE]
> GravitySend currently requires an older Flutter version (specified in [.fvmrc](.fvmrc))
> and thus build issues may be caused by a mismatch between the required and the (system-wide) installed Flutter version.  
> To make development more consistent, GravitySend uses [fvm](https://fvm.app) to manage the project Flutter version.
> After installing `fvm`, run `fvm flutter` instead of `flutter`.

## Contributing

We welcome contributions from anyone interested in helping improve GravitySend. If you'd like to contribute, there are a few ways to get involved:

### Translation

You can help translate GravitySend into other languages. We use the [Weblate](https://hosted.weblate.org/projects/GravitySend/app) platform to manage translations.

Alternatively, you can also contribute by forking this repository and adding translations manually.

The translations are located in the [app/assets/i18n](https://github.com/GravitySend/GravitySend/tree/main/app/assets/i18n) directory. Edit the `_missing_translations_<locale>.json` or `strings_<locale>.i18n.json` file to add or update translations.

<a href="https://hosted.weblate.org/engage/GravitySend/">
<img src="https://hosted.weblate.org/widget/GravitySend/app/multi-auto.svg" alt="Translation status" />
</a>

**_Take note:_ Fields decorated with `@` are not meant to be translated; they are not used in the app in any way, being merely informative text about the file or to give context to the translator.**

### Bug Fixes and Improvements

- **Bug Fixes:** If you find a bug, please create a pull request with a clear description of the issue and how to fix it.
- **Improvements:** Have an idea for how to improve GravitySend? Please create an issue first to discuss why the improvement is needed.

For more information, see the [contributing guide](https://github.com/GravitySend/GravitySend/blob/main/CONTRIBUTING.md).

## Troubleshooting

| Issue              | Platform (Sending) | Platform (Receiving) | Solution                                                                                                                                |
|--------------------|--------------------|----------------------|-----------------------------------------------------------------------------------------------------------------------------------------|
| Device not visible | Any                | Any                  | Make sure to disable AP-Isolation on your router. If it is enabled, connections between devices are forbidden.                          |
| Device not visible | Any                | Windows              | Make sure to configure your network as a "private" network. Windows might be more restrictive when the network is configured as public. |
| Device not visible | macOS, iOS         | Any                  | You can try to toggle the "Local Network" permission under "Privacy" in the OS settings.                                                |
| Speed too slow     | Any                | Any                  | Use 5 Ghz; Disable encryption on both devices                                                                                           |
| Speed too slow     | Any                | Android              | Known issue. https://github.com/flutter-cavalry/saf_stream/issues/4                                                                     |

## Building

These commands are intended for maintainers only. Make sure to run them from the `app` directory.

### Android

Traditional APK

```bash
flutter build apk
```

AppBundle for Google Play

```bash
flutter build appbundle
```

### iOS

```bash
flutter build ipa
```

### macOS

```bash
flutter build macos
```

### Windows

**Traditional**

```bash
flutter build windows
```

**Local MSIX App**

```bash
flutter pub run msix:create
```

**Store ready**

```bash
flutter pub run msix:create --store
```

### Linux

**Traditional**

```bash
flutter build linux
```

**AppImage**

```bash
appimage-builder --recipe AppImageBuilder.yml
```

**Snap**

Instructions in [GravitySend/snap/README.md](https://github.com/GravitySend/snap/blob/main/README.md)

## Contributors

<a href="https://github.com/GravitySend/GravitySend/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=GravitySend/GravitySend"  alt="GravitySend Contributors"/>
</a>
