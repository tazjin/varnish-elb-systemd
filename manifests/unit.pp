# Copy over a systemd unit and reload systemd

define varnish_elb_unit {
  exec { 'reload systemd':
    command     => 'systemctl daemon-reload',
    refreshonly => true,
  }

  file { "/usr/lib/systemd/system/${title}":
    ensure => present,
    notify => Exec['reload systemd'],
    source => "puppet:///modules/varnish_elb/${title}",
  }
}
