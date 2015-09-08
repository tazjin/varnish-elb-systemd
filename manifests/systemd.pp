# This class exists solely to provide systemd reloading functionality to the
# unit type.

class varnish_elb::systemd {
  exec { 'reload systemd':
    command     => '/usr/bin/systemctl daemon-reload',
    refreshonly => true,
  }
}
