# RPM Specs for HAproxy on CentOS / RHEL / Amazon Linux with default syslog

[![Github All Releases](https://img.shields.io/github/downloads/DBezemer/rpm-haproxy/total.svg)](https://github.com/DBezemer/rpm-haproxy/releases)

This repository contains some build artifacts of HAproxy that are provided with no support and no expectation of stability.
The recommended way of using the repository is to build and test your own packages.

Perform the following steps on a build box as a regular user.

## Install Prerequisites for RPM Creation

    sudo yum groupinstall 'Development Tools'

## Checkout this repository

    cd /opt
    git clone https://github.com/DBezemer/rpm-haproxy.git
    cd ./rpm-haproxy
    git checkout 2.0

## Vagrant build box

If you dont have a dedicated rpm build environment and don't want to mess up your local dev mechine
we have put together a Vagrantfile to quickly run a virtual build environment in VirtualBox.
Just run:

    Vagrant up
    vagrant ssh
    make

## Build using makefile

    make

Resulting RPM will be in /opt/rpm-haproxy/rpmbuild/RPMS/x86_64/

## Build haproxy with lua

    make build-with-lua

This goal is building haproxy with lua 5.3 binding.
The build relies on a yum repository with lua53 package available on the build host.
This lua53 package is right now an SPK internal packaging of lua 5.3.5.
We decided to crate our own lua packaging so that we could install it side by side
RedHats default installation.

## Credits

Based on the Red Hat 6.4 RPM spec for haproxy 1.4 combined with work done by

- [@nmilford](https://www.github.com/nmilford)
- [@resmo](https://www.github.com/resmo)
- [@kevholmes](https://www.github.com/kevholmes)
- Update to 1.8 contributed by [@khdevel](https://github.com/khdevel)
- Amazon Linux support contributed by [@thedoc31](https://github.com/thedoc31) and [@jazzl0ver](https://github.com/jazzl0ver)
- Version detect snippet by [@hiddenstream](https://github.com/hiddenstream)

Additional logging inspired by <https://www.percona.com/blog/2014/10/03/haproxy-give-me-some-logs-on-centos-6-5/>
