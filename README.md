<p align="center">
    <br />
    <br />
    <img src="img/IAR_GitHub_Banner.png" width="100%" alt="ImagineAR Logo" />
    <br />
    <br />
    <a href="https://cocoapods.org/pods/ImagineAR-SDK" alt="ImagineAR-SDK on CocoaPods" title="ImagineAR-SDK on CocoaPods"><img src="img/pod.svg" /></a>
    <img src="img/platform.svg" alt="Supported Platforms: iOS" />
</p>



# IAR-SDK-Sample-iOS

ImagineAR is an AR App development platform with tools to help you build, grow and monetize AR experiences on your products. More information can be found on the official ImagineAR website.
These samples showcase basic operations and features provided by each of the SDKs

# How to Get Started

- Clone these samples via `git clone`
- Run `pod install` on the sample that you want to test
- Open the workspace

# Basic Glossary

- **On Demand Markers** - each marker is an activation mechanism for an AR experience. On Demand Markers are the most generic ones, that can be activated at any time;
- **Location Markers** - contains location metadata and can be queried with a location parameter - Ideal for position dependent experiences;
- **Target/Image Markers** - are activated by using the device's camera, for the SDK to recognize determined images, where the AR experience will be projected onto;
- **Rewards** - scanning markers can unlock rewards to your users - from Images, to Coupon Codes, Videos or other types of assets;
- **AR Hunts** - hunts are multi-marker progressions, that rewards users who interact with a given set of markers;

# The Samples

## IAR-SurfaceSDK-Sample

This sample demonstrates basic usage of most features contained within the IAR-Surface-SDK:

- Environment surface detection;
- Projection of 3D assets, animations, shadows for the AR experience;
- Location Markers;
- On Demand Markers;
- NFC Read/Write (markers can be stored in a NFC tag, for On Demand activation);

![Surface SDK Sample](/img/surfaceSample.jpg)

## IAR-TargetSDK-Sample

Demonstrates usage of the IAR-Target-SDK:

- Scan/recognition of target markers;
- Video record/Take screenshot of AR experiences and share them inside your app;

To invoke target markers on the demonstration account, scan these images within the sample App:

- [Download images](https://iarv2storage.blob.core.windows.net/sdk-versions/TargetImages.zip)

![Target SDK Sample](/img/targetSample.jpg)

## IAR-CoreSDK-Sample

Demonstrates usage of the IAR-Core-SDK (that is also used on all other samples, as it manages the basic underlying entities):

- User Management;
- User Rewards (your users can acquire various kinds of rewards, such as Images, Videos, Coupon-Codes, etc - after interacting with some configured AR experiences);
- Location Markers (download markers according to a given location parameter);
- OnDemand Markers (API to list all OnDemand markers created on your developer account);
- ARHunts - API to list AR Hunts and the progression stats of the current user;

![Core SDK Sample](/img/coreSample.jpg)

## Common to all samples

All samples also demonstrates:

- User Management - How to CRUD Users (that can be assigned to your own user base) - they are basically the GUID IDs of your own user management system;
- Debug Tools - A set of feature toggles to help Developers preview features (Analytics, File logs, - - Debug layer, Surface detection points, generated shadows, light autodetection, simulate location)

# More Resources

Main Documentation: [ImagineAR Docs](https://docs.imaginear.com/)

# Requirements

Minimum deployment target of iOS 13.0

# License

The contents of this repository are licensed under the [Apache License, version 2.0.](https://www.apache.org/licenses/LICENSE-2.0)
The use of Imagine AR SDK is governed by the [Terms of Service for ImagineAR](https://imaginear.com/terms-conditions)

