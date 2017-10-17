# So you've bricked your TPCast...

Maybe you tried to upgrade it, or edited the Wifi connection settings and now it won't connect?

This guide will not tell you how to fix problems with Linux, it'll only tell you how to get back into the TPCast to fix them. It's assumed that if you started doing this, you should already have a basic understanding of what you're doing.

# STOP

If you're reading this for the first time, hopefully you came here at the start of another guide. Great.

Back up your SD card. refer to [The Harder Way](#The Harder Way) for more information on how to get your SD card out.

There's plenty of tools you can use to back up an SD card, though don't just copy everything in explorer. `dd` is the recommended tool to use though isn't available on Windows by default, and you can find more about how to backup a Raspberry Pi SD card [here](https://thepihut.com/blogs/raspberry-pi-tutorials/17789160-backing-up-and-restoring-your-raspberry-pis-sd-card).

## The Easy Way

Buy a USB to Ethernet adapter, plug it into the USB port you'd usually plug the headset into. This will let you make a wired connection to your network for debugging, and you can then SSH into the device again to fix whatever broke.

## The Harder Way

If the above doesn't work, something is wrong. Perhaps it won't boot at all? In which case, you need to open up the power brick.

1.) Remove all the screws from the casing, there's 4 of them, hiding under where the battery sits

2.) Pry the casing pieces away, you'll want to pull away but also upwards (up being in the direction of the USB and power ports to the HMD). You may need to use a bit of force here.

3.) Once you've got the case off, you should find a Micro SD card inside. The board should wiggle a bit so that you can pull the card out.

4.) Solve the problem manually using your PC and an SD card reader
