#!/bin/sh
# Prepare containers to run the test environment
# usage: ./container-setup.sh 15.0 15.1

for release; do
	OS_MAJOR=${release%.*}
	OS_MINOR=${release#*.}

	if ! [ $OS_MAJOR -ge 14 -a $OS_MAJOR -lt 16 -a $OS_MINOR -ge 0 ]; then
		echo "Not a supported FreeBSD release: ${release}" >&2
		exit 1
	fi

	podman build \
		--build-arg "FREEBSD_RELEASE=${release}" \
		--volume /usr/local/sbin/pkg-static:/bin/pkg \
		--env IGNORE_OSVERSION=yes \
		--env ABI=FreeBSD:${OS_MAJOR}:$(sysctl -n hw.machine_arch) \
		--env OSVERSION=$(printf "%d%02d000" $OS_MAJOR $OS_MINOR) \
		--no-hosts \
		--tag freebsd-puppet-test-infra:${OS_MAJOR}.${OS_MINOR} \
		--file podman/Containerfile
done
