# FreeBSD puppet@ test infrastructure

This repository include all the tooling to setup and test a FreeBSD puppet
infrastructure.  I use it while I put my puppet@ hat on to ensure I am not
introducing regressions, so feel free to use it for testing changes you would
like to propose, or for learning how to use Puppet on FreeBSD.

To run it, you MUST run FreeBSD and you MUST be able to run command as root
(e.g. with sudo) in order to create / manage jails.  The scripts currently use
bastille to do so, so `sysutils/bastille` MUST be installed.

## Getting started

This repository is a Puppet [control-repo] that contains a bunch of scripts to
setup the test infrastructure.  Check the `bin` directory if you are interested
in this aspect, otherwise this repository is a regular control-repo with simple
roles and profiles.

[control-repo]:https://github.com/puppetlabs/control-repo

## Bolt support

[Bolt] 3.27.1 introduced [transport for FreeBSD jails].  This repo is now also
a [Bolt project] that can target jails.  In the furure, the various scripts in
the `bin` directory may be replaced by tasks and plan to help covering Bolt
features and detect regressions in Bolt too.

[Bolt]:https://www.puppet.com/docs/bolt/latest/bolt.html
[transport for FreeBSD jails]:https://github.com/puppetlabs/bolt/pull/3170
[Bolt project]:https://www.puppet.com/docs/bolt/latest/running_bolt_commands.html
