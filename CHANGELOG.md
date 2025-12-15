# CascableCore GoPro Plugin 1.0.2

### Bug Fixes

- Fixed a bug that'd cause the Bluetooth permission to be prompted for as soon as the plugin was initialised (i.e., at app launch). It's now shown when camera discovery starts. [CORE-1114]

### Other Changes

- The GoPro plugin is now compiled against the CascableCore 17 API/SDK.


# CascableCore GoPro Plugin 1.0.1

### Bug Fixes

- Fixed a bug that'd cause the discovery of Bluetooth/WiFi cameras to fail after the first discovered camera. [CORE-1071]

- Improved the reliability of connecting to Bluetooth/WiFi cameras (in part to a change in CascableCore 16.0.1). [CORE-1070]

- Live view will now correctly recover on iOS/iPadOS/visionOS after the host app is put into the background. [CORE-1075]


# CascableCore GoPro Plugin 1.0

- Initial release.
