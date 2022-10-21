# puppet@ test infrastructure

This repository include all the tooling to setup and test a FreeBSD puppet
infrastructure.  I use it while I put my puppet@ hat on to ensure I am not
introducing regressions, so feel free to use it for testing changes you would
like to propose, or for learning how to use Puppet on FreeBSD.

To run it, you MUST run FreeBSD and you MUST be able to run command as root
(e.g. with sudo) in order to create / manage jails.  The scripts currently use
iocage to do so, so `sysutils/iocage` MUST be installed.

## Gestting started

This repository is a Puppet
[control-repo](https://github.com/puppetlabs/control-repo) that contains a
bunch of scripts to setup the test infrastructure.
