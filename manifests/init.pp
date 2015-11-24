# This type sets up a varnish-elb configuration including the systemd units
# necessary.
# Please note that this will not install Varnish, only the ELB configuration
# bits.

class varnish_elb(
  $elb_hostname,
  $varnish_director,
  $elb_port = '80',
  $connect_timeout = '3.5s',
  $first_byte_timeout = '60s',
  $between_bytes_timeout = '60s') {
    # Units that need to be copied over
    $varnish_elb_units = ['varnish-elb.service', 'varnish-elb.timer',
                          'varnish-reload@.path', 'varnish-reload.service']

    # Copy over units
    varnish_elb::unit{ $varnish_elb_units: }

    # Copy over VCL generation script
    file { '/usr/local/bin/generate_backends':
      ensure => present,
      mode   => '0755',
      source => 'puppet:///modules/varnish_elb/generate_backends',
    }
    # Create configuration file
    file { '/etc/default/varnish-elb':
      ensure  => present,
      content => template('varnish_elb/config.erb'),
    }

    # Enable and start VCL generation
    service { 'varnish-elb.timer':
      ensure  => running,
      enable  => true,
      require => [File['/usr/local/bin/generate_backends'],
                  File['/etc/default/varnish-elb'],
                  Varnish_elb::Unit[ $varnish_elb_units ]]
    }

    # Start Varnish reloader, this can not be enabled because systemd does not
    # support that functionality for template-units. However, Puppet should keep
    # it running anyways.
    service { "varnish-reload@${varnish_director}.path":
      ensure  => running,
      require => Varnish_elb::Unit[ $varnish_elb_units ],
    }
  }
