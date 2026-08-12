class profile_postgresql::install {

  package { $profile_postgresql::package_names:
    ensure  => installed,
    require => Class['profile_postgresql::repo'],
  }

  package { 'libpq-dev':
    ensure => installed,
  }
}
