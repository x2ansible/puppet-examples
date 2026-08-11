# Manage HAProxy service lifecycle.
class profile_haproxy::service {

  # Systemd override to load conf.d/ fragments alongside main config
  file { '/etc/systemd/system/haproxy.service.d':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { '/etc/systemd/system/haproxy.service.d/override.conf':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => @("EOF")
      [Service]
      ExecStart=
      ExecStart=/usr/sbin/haproxy -Ws -f ${profile_haproxy::config_file} -f ${profile_haproxy::config_dir}/conf.d/ -p /run/haproxy.pid -S /run/haproxy-master.sock
      | EOF
    ,
    require => File['/etc/systemd/system/haproxy.service.d'],
    notify  => Exec['haproxy_systemd_reload'],
  }

  exec { 'haproxy_systemd_reload':
    command     => 'systemctl daemon-reload',
    path        => ['/usr/bin', '/bin'],
    refreshonly => true,
  }

  service { $profile_haproxy::service_name:
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => [Package[$profile_haproxy::package_name], Exec['haproxy_systemd_reload']],
    subscribe  => File[$profile_haproxy::config_file],
  }

  # Validate config before restart
  exec { 'haproxy_config_check':
    command     => "haproxy -c -f ${profile_haproxy::config_file} -f ${profile_haproxy::config_dir}/conf.d/",
    path        => ['/usr/sbin', '/usr/bin', '/sbin', '/bin'],
    refreshonly => true,
    subscribe   => File[$profile_haproxy::config_file],
    before      => Service[$profile_haproxy::service_name],
  }

  # Log rotation
  file { '/etc/logrotate.d/haproxy':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => @("EOF")
      /var/log/haproxy/*.log {
          daily
          rotate 14
          missingok
          notifempty
          compress
          delaycompress
          sharedscripts
          postrotate
              /bin/kill -HUP $(cat /var/run/haproxy.pid 2>/dev/null) 2>/dev/null || true
          endscript
      }
      | EOF
  }
}
