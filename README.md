# mausb
mausb is a command line tool for managing (mount/unmount/list) usb storage devices.

## Installation

mausb requires the tools `df`, `readlink`, and `udisksctl`.

A .gem file can be built by:

```sh
git clone https://github.com/cetinkaya/mausb.git
cd mausb
gem build mausb.gemspec
```

To install the local gem file, use:

```sh
gem install --local mausb-0.1.gem
```

## Examples

`mausb` tries to guess what you want to do. So if you have a single connected device that is not yet mounted, running

```sh
mausb
```

will result in mounting of that device by means of executing `udisksctl mount -b DEVICE-LINK`.

If on the other hand, if you have a single mounted device (and no other connected devices), running `mausb` will result in unmounting of that device. If you have two or more connected devices running `mausb` will ask you what to do.


You can also run `mausb m` for mounting connected devices; `mausb u` for unmounting already mounted devices; `mausb l` for listing all connected devices (mounted or unmounted).