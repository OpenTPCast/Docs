# Upgrading Rasbian and the Kernel

**NOTE: This is done at you own risk. We (the collective group contributing to this repository) take no responsibility for any harm done to your TPCast.**

If you brick it, check out [Unbricking](UNBRICKING.md).

# STOP

Don't go any further. Read [Unbricking](UNBRICKING.md) so you know what you're getting into. If you don't think you can fix things if you break something, don't read on, don't pass GO, don't collect £200. Be happy with what you have right now and continue using it.

## Upgrading

1.) SSH into your TPCast. If you don't know how to do that, check out the [SSH](SSH.md) guide.

2.) Open `/etc/apt/sources.list` in your preferred text editor (`vim`,`nano`, etc) and replace all instances of `jessie` with `stretch`

3.) Do the same in `etc/apt/sources.list.d/raspi.lis`

4.) Run `sudo apt-get update`

5.) Run `sudo apt-get dist-upgrade -y`

6.) Wait patiently as Raspbian updates to the latest version: Stretch. Grab a sandwich, pull up Netflix. This is gonna take a while but will need a little babysitting.

7.) Whenever it asks whether you want to keep your existing file of something, say yes (just press enter, it's the default)
