# logger3

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Debug over WiFi

USB-port is used for USB-Hub. So, we must debug app over WiFi.

    adb kill-server

Connect device by cabble

    adb tcpip 5555

Disconnect device. Look IP on settings->WiFi->Info

    adb connect 192.168.31.212
