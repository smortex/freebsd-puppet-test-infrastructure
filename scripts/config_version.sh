#!/bin/sh

if [ $# -ne 2 -o ! -d "$1" -o ! -d "$1/$2" ]; then
  echo "usage: $0 <environmentpath> <environment>" >&2
  exit 1
fi

if [ -x /opt/puppetlabs/puppet/bin/ruby ]; then
  ruby=/opt/puppetlabs/puppet/bin/ruby
elif [ -x /usr/local/bin/ruby ]; then
  ruby=/usr/local/bin/ruby
fi

"${ruby}" "$1/$2/scripts/code_manager_config_version.rb" "$1" "$2"
