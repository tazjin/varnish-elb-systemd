# This type sets up a varnish-elb configuration including the systemd units
# necessary.
# Please note that this will not install Varnish, only the ELB configuration
# bits.

class varnish_elb($elb_hostname, $varnish_director) {
  # Units that need to be copied over
  $varnish_elb_units = ['varnish-elb.service', 'varnish-elb.timer',
                        'varnish-reload@.path', 'varnish-reload.service']

  # The services that need to be enabled and started
  $varnish_elb_services = ['varnish-elb.timer',
                           "varnish-reload@${varnish_director}"]

  # Copy over units
  varnish_elb::unit{ $varnish_elb_units: }

  # Create configuration file
  template { '/etc/default/varnish-elb':
    ensure  => present,
    content => template('varnish-elb'),
  }

  # Enable and start services
  service { $varnish_elb_services:
    ensure => running,
    enable => true,
  }
}
