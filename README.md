Varnish + ELB + systemd
=======================

This repository provides a script and several systemd-units to allow for using
Varnish in combination with an AWS Elastic Load Balancer, or theoretically any
backend that has constantly changing DNS records.

The script itself can be used without systemd as well, but the units here are
provided for convenience.

## Script overview

The script is supposed to run periodically. It takes the target hostname and a
name to use for the Varnish director as its arguments. The director name is also
used for the VCL file name at `/etc/varnish/${DIRECTOR}.vcl`.

When run it will resolve the provided hostname and create a director with an
entry for every A record that the hostname eventually resolves to.

The configuration is written to a temporary file and only replaced at the
specified path if the records have changed.

## Units overview

There are two pairs of related units included. To make this setup work two
things need to be done:

* regenerating the Varnish configuration periodically
* reloading Varnish if the configuration changes

The two unit pairs tackle these tasks separately.

`varnish-elb.{timer|service}` provide a pair that will periodically run the
script. This is configured to run every 30 seconds, half the TTL of an ELB A
record.

`varnish-elb[@].{path|service}` provides a path unit that watches the specified
VCL file (presumed to be in `/etc/varnish`) and triggers the reload unit if the
VCL changes.

## Configuration

A simple environment file in `/etc/defaults/varnish`:

```
TARGET_HOSTNAME=some-elb-instance.elb.amazonaws.com
DIRECTOR=elb
```

## Puppet usage example

The Puppet module can be used as such:

```puppet
include { 'varnish_elb':
    elb_hostname     => 'some-elb-instance.elb.amazonaws.com',
    varnish_director => 'elb,'
}
```
