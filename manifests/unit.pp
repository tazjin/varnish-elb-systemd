# Copy over a systemd unit and reload systemd

define varnish_elb::unit {
  include varnish_elb::systemd

  file { "/usr/lib/systemd/system/${title}":
    ensure => present,
    notify => Exec['reload systemd'],
    source => "puppet:///modules/varnish_elb/${title}",
  }
}
