# FreeBSD OpenVox (legcy Puppet) test infrastructure

This repository include all the tooling to setup and test a FreeBSD OpenVox infrastructure.
This infrastructure is composed of a bunch of nodes setup as jails by `sysutils/podman`:

* `puppet` - OpenVox-Server
* `puppetdb` - OpenVoxDB + PostgreSQL database
* `puppetboard` - PuppetBoard
* `node1`, `node2` - Sample nodes, `node1` is used to verify that [Choria] is working as expected.

[Choria]:https://choria.io/

I (romain@) use it while I put my puppet@ hat on to ensure I am not introducing regressions.
Feel free to use it for testing changes you would like to propose, or for learning how to use OpenVox on FreeBSD.

## Getting started

This repository is an OpenVox [control-repo] that contains a bunch of scripts to setup the test infrastructure.
Check the `bin` directory if you are interested in this aspect, otherwise this repository is a regular control-repo with simple [roles and profiles].

So you first need to [install and configure Podman].
Adjust the location of your packages in `bin/podman/Containerfile` as they will be different from what I use on my laptop.
Then create the base image by specifying the FreeBSD version (e.g. `15.1`) you want to use:

```
# cd bin && ./container-setup.sh 15.1
```

You are now ready setup the infrastructure by specifying the FreeBSD version (e.g. `15.1`) and the OpenVox version (e.g. `9`) to use:

```
# cd bin && ./build-openvox-infrastructure.sh 15.1 9
```

[control-repo]:https://github.com/puppetlabs/control-repo
[roles and profiles]:https://www.youtube.com/watch?v=RYMNmfM6UHw
[install and configure Podman]:https://docs.freebsd.org/en/books/handbook/containers/#containers-podman-intro

## Bolt support

[Bolt] 3.27.1 introduced [transport for FreeBSD jails].
This repo is now also a [Bolt project] that can target jails.
In the furure, the various scripts in the `bin` directory may be replaced by tasks and plan to help covering Bolt features and detect regressions in Bolt too.

[Bolt]:https://www.puppet.com/docs/bolt/latest/bolt.html
[transport for FreeBSD jails]:https://github.com/puppetlabs/bolt/pull/3170
[Bolt project]:https://www.puppet.com/docs/bolt/latest/running_bolt_commands.html
