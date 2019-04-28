Embedded Microcontroller software builder
=========================================

This project allows the Linux machine to build all software necessary
to use the real-time embedded microcontroller (EC) along with the host
system. The USB interface is used to communicate between the host and
the controller. The software includes a Linux [kernel module] and a
user space application that provides control of the EC.

Before building it is necessary to initialize all SDK resources and
git submodules:

```bash
	(shell)$ cd /path/to/sdk
	(shell)$ make init
```
The command "info" allows you to get information about all files in
the SDK:

```bash
	(shell)$ make info
```

Build
-----
```bash
	(shell)$ make all
	(shell)$ make cleanall
```

Building or cleaning only the kernel module:

```bash
	(shell)$ make
	(shell)$ make default
	(shell)$ make clean
```

User application example build (clear) only:

```bash
	(shell)$ make app
	(shell)$ make cleanapp
```

Print information about SDK:

```bash
	(shell)$ make info
	(shell)$ make help
```

Load or unload module:

```bash
	(shell)$ make install
	(shell)$ make remove
```

[kernel module]: https://github.com/maxpoliak/fabric-ec
