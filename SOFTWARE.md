# What makes the TPCast tick?

Well...

## The Power Brick

The power brick runs Raspbian Jessie, for an ARMv7 CPU.

### USB Forwarder

TPCast have a custom version of [USB Network Gate](https://www.eltima.com/products/usb-over-ethernet/) by Eltima. It doesn't support higher the Linux Kernel 4.4 according to the website so this may well be why the microphone doesn't work (see [Kernel Issues](#kernel-issues) below).

How do we know it's USBNG? Download their client, open it, run the TPCast software and connect to the brick and watch as the USBNG software detects your connected devices as remote devices.

![USB Network Gate giving the game away](img/usbng.png)

### Kernel Issues

The Linux Kernel used by the TPCast is version 4.4, which has a bug that causes issues with Isochronous USB devices such as microphones and webcams. It doesn't affect _all_ USB mics and webcams but the Vive's are indeed affected by this.

We have tried unsuccessfully to install a newer Kernel (4.9) on the TPCast, but have so far fallen flat due to kernel module problems with the Wifi chip in the TPCast. Still working on that one!
