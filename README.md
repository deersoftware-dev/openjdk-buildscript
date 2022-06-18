# DeerSoftware OpenJDK Buildscripts

Scripts to automatically compile and package supported versions of OpenJDK by DeerSoftware (DeerSoftware OpenJDK).

## Architectures supported

For now, only the x86_64 (amd64) architecture is supported, later on it is possible we can also support aarch64 (armv8), but don't expect the same from x86 (ia86) as neither Windows 11 nor modern Linux distros are available. giving more support to this architecture.

## About MacOS support

DeerSoftware is currently unable to provide support or official builds for MacOS or other Apple systems, but that does not mean that we will not support community support for such systems.

## OpenJDK versions supported

We only support versions 8 LTS and 17 LTS, as they are the most used and updated respectively.

## Building in Linux

| OS           | Supported          |
| ------------ | ------------------ |
| Arch Linux   | :white_check_mark: |
| Debian 11    | *Not tested*       |
| Debian 10    | *Not tested*       |
| Fedora 36    | *Not tested*       |
| Fedora 35    | *Not tested*       |
| Ubuntu 22.04 | *Not tested*       |
| Ubuntu 20.04 | *Not tested*       |

## Building in Windows

| OS         | Supported          |
| ---------- | ------------------ |
| Windows 11 | *Not tested*       |
| Windows 10 | :white_check_mark: |

## Arch Linux: Building OpenJDK 17

- base
- base-devel
- jdk17-openjdk

```sh
bash openjdk.sh
```

## Arch Linux: Building OpenJDK 8

- base
- base-devel
- jdk8-openjdk

```sh
bash openjdk8.sh
```

## Windows: Building OpenJDK 17

- autoconf
- Cygwin
- make
- OpenJDK 17
- unzip
- Visual Studio 2022 Build Tools with C++ module
- zip

```sh
bash openjdk-win.sh
```

### Windows: Building OpenJDK 8

- autoconf
- Cygwin
- make
- OpenJDK 8
- unzip
- Visual Studio 2015 Community Edition with Visual C++
- wget
- zip

```sh
bash openjdk8-win.sh
```

## Credits

DeerSoftware OpenJDK is a project by [DeerSoftware](https://www.deersoftware.dev/).  
OpenJDK is a project by [Oracle Corporation](https://www.oracle.com/).  
Build instructions extracted from PKGBUILDs used in [Arch Linux](https://archlinux.org/).
