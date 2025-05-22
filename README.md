# CascableCore GoPro Plugin

This plugin adds support for GoPro cameras via USB and Bluetooth/WiFi to [CascableCore](https://developer.cascable.se/), from the GoPro HERO 9 and up. Exact functionality will depend on what each particular model supports. In general, only "Black" models are supported (i.e., the GoPro HERO 13 Black).

**Important:** Make sure your GoPro camera is updated to the latest available firmware version. Some cameras have bugs in older firmware versions that will prevent the camera working with CascableCore.


### Supported Features

With this plugin, CascableCore is the best GoPro SDK for Apple platforms on the market, supporting everything you need to create fully-featured integrations with GoPro cameras:

✅ Support for connections via USB and Bluetooth/WiFi, including bootstrapping a WiFi connection via Bluetooth and getting the device your app is running on connected to the GoPro's WiFi hotspot.

✅ High-performance, hardware-accelerated live view streams from all supported cameras.

✅ Photo and video metadata, thumbnails, and full-quality file transfer.

✅ Inspect and set on-camera settings.

Combined with CascableCore's easy-to-use API, you'll be up and running in no time!


### An Important Note About Live View

GoPro cameras - particularly newer models — deliver their live view via high-resolution, high-framerate video feeds.

CascableCore takes care of this for you. **However**, in the default configuration, the SDK will decode video frames all the way to `NSImage`/`UIImage` objects. This is a heavy operation at the best of times, but a GoPro feed will happily completely max out a CPU core when being decoded into image objects in this way, resulting in poor performance, dropped frames, and high energy usage.

GoPro live view frames are delivered as 24-bit RGB pixel buffers, and we highly recommend turning on the `CBLLiveViewOptionSkipImageDecoding` live view option (or `.skipImageDecoding` if using [CascableCoreSwift](https://github.com/Cascable/cascablecore-swift)) and rendering the live view feed using Metal or some other high-performance pixel buffer renderer. This will provide a much better experience for your users.

[CascableCoreSwift](https://github.com/Cascable/cascablecore-swift) includes an easy-to-use Metal-backed live view renderer for you to use if you don't have an existing stack in your app.

**Important:** CascableCore uses the host device's hardware video decoders for this work, which aren't available to the iOS Simulator. As such, live view will not work in the Simulator.


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

- Mac: An `Info.plist` string value for `NSLocationUsageDescription` must be present if your application wants to use the automatic WiFi network joining functionality. If you wish to instruct your users to manually connect to the GoPro's WiFi network, this can be omitted.


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

if config.requiresLocationPermissionForNetworkConnections {
    // See the section below for handling WiFi network switching. 
}

let cameraDiscovery = CameraDiscovery.shared
cameraDiscovery.delegate = self
cameraDiscovery.beginSearching()
```

The `GoProCameraConfiguration` struct has the following properties:

- **deferWiFiNetworkJoiningToClient**: Whether to defer managing WiFi networks to the client (i.e., your code). Defaults to `false`. By default, the GoPro plugin will try to connect to the GoPro camera's WiFi network on your behalf, prompting the user in the process. If you'd like to be in control of this (perhaps you'd prefer to instruct your users to connect to the network manually), set this property to `true`. When set to `true`, you'll be asked to switch networks during connection via the camera authentication mechanism during connection. 

- **promptForLocationPermissionIfNeeded**: Whether to automatically prompt the user for location permission if it's required to connect to the GoPro camera's WiFi network.

- **requiresLocationPermissionForNetworkConnections**: A get-only property that tells you if your application needs to ask the user for permission to access their location before connecting to a GoPro camera via WiFi. If this returns `true`, you must either allow the GoPro plugin to prompt for location authorisation on your behalf, or manually gain location authorisation (i.e., `CLLocationManager.requestWhenInUseAuthorization()`) before WiFi connections can succeed. If the user declines to provide such permission, set `deferWiFiNetworkJoiningToClient` to `false` and prompt the user to connect to the network manually instead (or connect via USB).


### Camera Connection, Core Location, and Joining WiFi Networks

The connection process for GoPro cameras can be rather involved, and CascableCore will take care of this for you as much as it can.

The most complicated part of this process is joining the camera's WiFi network. By default, the GoPro plugin will default to switching the user's device over to that network for you.

**Important:** The process of connecting to a GoPro's WiFi network can take upwards of 30 seconds - it's important to present appropriate UI in your app so the user knows what's happening. CascableCore has a robust set of checks and timeouts, so if a problem does occur you *will* get a connection failure callback.

**Important:** The iOS Simulator does not provide access to the host device's WiFi system, and as such this automatic process will not work in the Simulator. Setting `deferWiFiNetworkJoiningToClient` to `true` for Simulator builds and manually joining the given network on the host Mac will work, however.

In some circumstances, CascableCore can't switch the device's connected WiFi network unless your app has been granted permission to access the user's location via `CLLocationManager`. To check this, check the `requiresLocationPermissionForNetworkConnections` property on your `GoProCameraConfiguration` object. If the property is `true`, you must either allow the GoPro plugin to prompt for location authorisation on your behalf, or obtain location permission (i.e., via `CLLocationManager.requestWhenInUseAuthorization()`) from the user before connections to GoPro cameras can succeed via WiFi.

If the user declines this permission (or you don't want to ask for it), you must set `deferWiFiNetworkJoiningToClient` on your configuration object (and `apply()` the change) to stop CascableCore trying and failing to switch the WiFi network over for you, instead handling the need to switch networks yourself by popping up a dialog to your user asking them to connect to the network manually. You could also disable the option to connect to GoPro cameras via WiFi entirely, if you prefer.

If you try to perform a connection that'd require location permission to be granted without actually getting such permission, the connection to the camera will fail with the `CBLErrorCodeRequiresLocationAuthorization` error code.

#### Pseudocode Examples

This example implements the situation where we want location permission prompting and network joining to be handled automatically by CascableCore:

```swift
// With this configuration, everything will be handled on our behalf.
var config: GoProCameraConfiguration = .default
config.deferWiFiNetworkJoiningToClient = false
config.promptForLocationPermissionIfNeeded = true
config.apply()

let cameraDiscovery = CameraDiscovery.shared
cameraDiscovery.delegate = self
cameraDiscovery.beginSearching()

// Later, when we find a GoPro camera.
camera.connect(authenticationRequestCallback: { context in
    // We need to handle various camera authentication methods 
    // (manual network joining, asking for passwords, etc.)
}, authenticationResolvedCallback: {
    // Close any remaining authentication dialogs we've shown.
}, completionCallback: { error, warnings in
    // Handle success or failure.
    switch error.asCascableCoreError {
    case .networkChangeFailed: 
        // CascableCore was unable to connect to the GoPro camera's WiFi network.
    case .requiresLocationAuthorization: 
        // Connecting to WiFi networks requires location auth, and we don't have it.
    case …:
        // There are other errors too!
    }
})
```

    CBLErrorCode = 1029,
    /** The operation failed because it requires that the application has been granted an authorisation to use location services. */
    CBLErrorCodeRequiresLocationAuthorization = 1030,

This example implements the situation where we want to present our own custom location permission UI, but want CascableCore to handle connecting to the GoPro's WiFi network for us unless it's impossible to do so. If that's the case, we'll instead present a dialog to the user asking them to connect to the network manually.

```swift
var config: GoProCameraConfiguration = .default
config.promptForLocationPermissionIfNeeded = false
config.apply()

if config.requiresLocationPermissionForNetworkConnections {
    let hasLocationPermission: Bool = askForLocationPermission()
    if !hasLocationPermission {
        // We need location permission to auto-switch WiFi networks,
        // but we don't have it. We must disable that option.
        config.deferWiFiNetworkJoiningToClient = true
        config.apply()
    }
}

let cameraDiscovery = CameraDiscovery.shared
cameraDiscovery.delegate = self
cameraDiscovery.beginSearching()

// Later, when we find a GoPro camera.
camera.connect(authenticationRequestCallback: { context in
    switch context.type {
    case .connectToWiFiNetwork:
        // CascableCore is asking us to connect to the GoPro's WiFi network.
        // We can ask the user to do it then click a button once they're done.
        let ssid = context.wiFiNetworkSSID
        let password = context.wiFiNetworkPassword
        let message = "Please connect to the network \(ssid) with password \(password)."

        let result = displayDialog(message, completionHandler: { result in
            if result == .done {
                context.submitHasConnectedToWiFiNetwork()
            } else {
                context.submitCancellation()
            }
        })
    case …: // We need to handle other camera authentication methods too.
    }
}, authenticationResolvedCallback: {
    // Close any remaining authentication dialogs we've shown.
}, completionCallback: { error, warnings in
    // Handle success or failure.
})
```
