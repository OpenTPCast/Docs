# TPCast & OpenTPCast Resources

This repository provides resources and documentation that are relevant to the TPCast, and the OpenTPCast upgrade project.

## Official Support Status
|                      | **Auxiliary USB Port**    | **Microphone**            | **Camera** |
| -------------------- | :-----------------------: | :-----------------------: | :--------: |
| **HTC Vive (CN)**    | :x: <sup>[[1]](#f1)</sup> | :white_check_mark: <sup>[[2]](#f2)</sup> | :x:        |
| **HTC Vive (US/EU)** | :x: <sup>[[1]](#f1)</sup> | :white_check_mark: <sup>[[2]](#f2)</sup> | :x:        |
| **Oculus Rift**      |                           | :white_check_mark: <sup>[[2]](#f2)</sup> |            |

<sup><a name="f1">[1]</a></sup> *Provides power to connected devices.*

<sup><a name="f2">[2]</a></sup> *Requires TPCast firmware update which can be obtained through official TPCast support channels.*

## OpenTPCast Support Status
|                      | **Auxiliary USB Port** | **Microphone**     | **Camera**                                                                           |
| -------------------- | :--------------------: | :----------------: | :----------------------------------------------------------------------------------: |
| **HTC Vive (CN)**    | :white_check_mark:     | :white_check_mark: | :white_check_mark: <sup>[[3]](#f3)</sup> <sup>[[4]](#f4)</sup> <sup>[[5]](#f5)</sup> |
| **HTC Vive (US/EU)** | :white_check_mark:     | :white_check_mark: | :white_check_mark: <sup>[[3]](#f3)</sup> <sup>[[5]](#f5)</sup>                       |
| **Oculus Rift**      |                        | :white_check_mark: |                                                                                      |

<sup><a name="f3">[3]</a></sup> *Experimental SteamVR camera support requires a third party router and software workarounds for older revisions of the HTC Vive.*

<sup><a name="f4">[4]</a></sup> *Due to the large bandwidth requirements, Chinese TPCast kits for HTC Vive will also require a third party 802.11AC capable Wi-Fi adapter in addition to a third party router to enable experimental native SteamVR camera support.*

<sup><a name="f5">[5]</a></sup> *A software workaround to use the HTC Vive camera with stock TPCast hardware is available, please refer to [Using The OpenTPCast Camera Service](guides/CAMERASTREAM.md) for more information.*

## Resources

### TPCast Information
- [Hardware Teardown & Specifications](HARDWARE.md)
- [Software](SOFTWARE.md)

### OpenTPCast Guides
- [Upgrading The TPCast To OpenTPCast](guides/UPGRADE.md)
- [Using The OpenTPCast Camera Service](guides/CAMERASTREAM.md)
- [Preparing A OpenTPCast Image (Maintainer's Guide)](guides/PREPAREIMAGE.md)

### Tinkering Guides
- [Backing Up & Restoring A TPCast Power Box MicroSD Card](guides/SDCARD.md)
- [Optimizing The TPCast Router](guides/ROUTER.md)

### Miscellaneous
- [Contributing](CONTRIBUTING.md)
- [Community Discord](https://discord.gg/kAbqRGC)
