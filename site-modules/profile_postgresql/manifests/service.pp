class profile_postgresql::service {

  service { $profile_postgresql::service_name:
    ensure  => running,
    enable  => true,
    require => Class['profile_postgresql::install'],
  }
}
