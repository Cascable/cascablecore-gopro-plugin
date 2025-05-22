# CascableCore GoPro Plugin

This plugin adds support for GoPro cameras via USB and Bluetooth/WiFi, from the GoPro HERO 9 and up. Exact functionality will depend on what each particular model supports. In general, only "Black" models are supported (i.e., the GoPro HERO 13 Black).

**Important:** Make sure your GoPro camera is updated to the latest available firmware version. Some cameras have bugs in older firmware versions that will prevent the camera working with CascableCore.

### 🚨 Beta Notes 🚨

This plugin is currently in early beta. Please give feedback for any bugs and feature requests before the target final release date in June.

#### Known Issues

- Live view is not currently implemented. This will be added before the first non-beta release.

- Automatic WiFi network switching on macOS is very unreliable. We recommend instructing the user to switch networks manually on the Mac for now - see "Configuring the GoPro Plugin" below. It's much better on iOS.

- Setting the video quality property may fail for some values.

- The number of available properties is fairly small. We're working on adding more settings.


### Setting Up Your Project for GoPro Cameras

Communication with GoPro cameras involves Bluetooth and local network connections. In order for this to operate correctly, you need to declare the following entitlements.

**Note:** USB-connected GoPro cameras implement their communication using a network-over-USB protocol, so they're covered under networking permissions and rules despite being connected via a USB cable. This is largely an implementation detail and is only important when declaring pemissions in your app's entitlements and `Info.plist`, and when permission prompts are shown to the user by the operating system. Otherwise, to avoid user confusion, they should be described as USB-connected (and CascableCore does so).

#### To Connect Via Any Means

- All platforms: In the `NSBonjourServices` `Info.plist` array, there must be a `_gopro-web._tcp` entry.

- All platforms: In the `NSAppTransportSecurity` `Info.plist` dictionary, `NSAllowsLocalNetworking` must be set to `true`.

- All platforms: An `Info.plist` string value for `NSLocalNetworkUsageDescription` must be present.

#### To Connect Via Bluetooth/WiFi

- All platforms: An `Info.plist` string value for `NSBluetoothAlwaysUsageDescription` must be present.

- iOS: The `com.apple.developer.networking.HotspotConfiguration` (**Hotspot**) entitlement must be enabled.

- iOS: The `com.apple.developer.networking.wifi-info` (**Access Wi-Fi Information**) entitlement must be enabled.

- Mac: The `com.apple.security.device.bluetooth` (**Bluetooth**) Sandbox entitlement must be enabled.

- Mac: The `com.apple.security.network.client` (**Outgoing Connections (Client)**) Sandbox entitlement must be enabled.


### Adding the GoPro Plugin to Your Project

Adding the CascableCore GoPro plugin to your project is easy - simply add this package to your project as you would any other Swift Package Manager package, then `import CascableCoreGoPro` near your camera connection code. The CascableCore plugin system will pick up and load the plugin when your application runs.

**Note:** Since the GoPro plugin is built alongside CascableCore, it has fairly tight version requirements to the CascableCore distribution package.

Plugin loading is done via the CascableCore `CameraDiscovery` class. You can check that the plugin is loaded by checking the `loadedPluginIdentifiers` property:

```swift
import CascableCore
import CascableCoreGoPro

let cameraDiscovery = CameraDiscovery.shared

if cameraDiscovery.loadedPluginIdentifiers.contains(GoProCameraEntryPoint.pluginIdentifier) {
    print("GoPro plugin is loaded!")
}
```

CascableCore enables all plugins by default. You can, if you choose, disable it at runtime.

```swift 
cameraDiscovery.setEnabled(false, forPluginWithIdentifier: GoProCameraEntryPoint.pluginIdentifier)

if cameraDiscovery.enabledPluginIdentifiers.contains(GoProCameraEntryPoint.pluginIdentifier) {
    print("GoPro plugin is enabled!")
}
```

Once added and enabled (or, rather, not disabled), GoPro cameras will be detected through the same camera discovery process you'd use for any other camera.


### Configuring the GoPro Plugin

The plugin is set up with sensible defaults, but you can configure aspects of it to suit your needs via the `GoProCameraConfiguration` struct.

**Important:** You must apply configuration changes before starting camera discovery in CascableCore. The best way to ensure this is to apply your changes before calling `beginSearching()` on the `CameraDiscovery` object:

```swift  
import CascableCore
import CascableCoreGoPro

var config: GoProCameraConfiguration = .default
config.deferWiFiNetworkJoiningToClient = true
config.apply() // You *must* call this method for changes to take effect.

let cameraDiscovery = CameraDiscovery.shared
cameraDiscovery.delegate = self
cameraDiscovery.beginSearching()
```

The `GoProCameraConfiguration` struct has the following properties:

- **deferWiFiNetworkJoiningToClient**: Whether to defer managing WiFi networks to the client (i.e., your code). Defaults to `false`. By default, the GoPro plugin will try to connect to the GoPro camera's WiFi network on your behalf, prompting the user in the process. If you'd like to be in control of this (perhaps you'd prefer to instruct your users to connect to the network manually), set this property to `true`. When set to `true`, you'll be asked to switch networks during connection via the camera authentication mechanism during connection. 
