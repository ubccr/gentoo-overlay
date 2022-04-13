# CCR Gentoo overlay

This is a custom [ebuild repository](https://wiki.gentoo.org/wiki/Ebuild_repository) 
for use with CCR's compatability layer.

## About

To ensure all software runs on any compute node no matter what OS distro is
installed, we use [Gentoo Prefix](https://wiki.gentoo.org/wiki/Project:Prefix)
as the compatability layer.

This repo provides the recipes (ebuilds) for various packages and software used
at CCR. This is similar to custom yum/apt repos where we put custom builds of
our software. One subtle difference is gentoo builds everything from source, so
ebuilds define recipes on how to build software and will set the sysroot of
configure/make to point at our gentoo prefix install.

We also create custom [package sets](https://wiki.gentoo.org/wiki/Package_sets#User_defined_sets) 
which define the software to be installed in the compatability layer.

## Usage

_NOTE: these are currently very much a WIP_

1. Bootstrap gentoo prefix. [See here](https://wiki.gentoo.org/wiki/Project:Prefix/Bootstrap)

2. Install a few required gentoo packages:

```
$ emerge --ask gentoolkit
$ emerge --ask dev-vcs/git
$ emerge --ask app-eselect/eselect-repository
$ mkdir -p /etc/portage/repos.conf
```

3. Clone this repo into `/var/db/repos`:

```
$ cd $EPREFIX/var/db/repos
$ git clone https://github.com/ubccr/gentoo-overlay.git ubccr
```

4.  Create these two files:

```
$ cat $EPREFIX/etc/portage/repos.conf/ubccr.conf 
[ubccr]
location = /PATH/TO/EPREFIX/var/db/repos/ubccr
sync-type = git
sync-uri = https://github.com/ubccr/gentoo-overlay.git
masters = gentoo
priority = 50
auto-sync = yes

$ cat $EPREFIX/etc/portage/repos.conf/gentoo.conf 
[gentoo]
sync-type = webrsync
auto-sync = no
```

5. Add symlinks to portage configs:

```
# symlink everything in etc/portage to $EPREFIX/etc/portage
$ ln etc/portage/package.* $EPREFIX/etc/portage/
$ ln etc/portage/sets $EPREFIX/etc/portage/sets
$ ln etc/portage/env $EPREFIX/etc/portage/env
```

6.  Fix locale in EPREFIX:

```
$ vim ${EPREFIX}/etc/locale.gen
Uncomment this line:
en_US.UTF-8 UTF-8

$ locale-gen

$ eselect locale list
Available targets for the LANG variable:
  [1]   C
  [2]   C.utf8
  [3]   POSIX
  [4]   en_US.utf8
  [ ]   (free form)

$ eselect locale set 4
```

7. Make sure that glibc is always compiled with a user-defined-trusted-dirs option

```
$ equery has --package glibc EXTRA_EMAKE
(this should return nothing)

# (Re)install glibc with the user-defined-trusted-dirs option
$ EXTRA_EMAKE="user-defined-trusted-dirs=/eprefix/path/host_injections/[CCR_VERSION]/compat/linux/x86_64/lib" emerge --ask --oneshot sys-libs/glibc

$ equery has --package glibc EXTRA_EMAKE
user-defined-trusted-dirs=/eprefix/path/host_injections/[CCR_VERSION]/compat/linux/x86_64/lib
```

8. Install packages from package set:

```
$ emerge --ask --update --newuse --deep --complete-graph --verbose @ubccr-2021.12-linux-x86_64
```

## See Also

The config files and ebuilds in this repo were heavily adopted from [EESSI](https://github.com/EESSI) 
and [Compute Canada](https://github.com/ComputeCanada). You can check out their overlays here:

- https://github.com/EESSI/gentoo-overlay
- https://github.com/ComputeCanada/gentoo-overlay
