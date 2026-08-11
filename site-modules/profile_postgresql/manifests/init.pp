class profile_postgresql (
  String        $version      = lookup('profile_postgresql::version'),
  Array[String] $package_names = lookup('profile_postgresql::package_names'),
  String        $service_name = lookup('profile_postgresql::service_name'),
) {

  contain profile_postgresql::repo
  contain profile_postgresql::install
  contain profile_postgresql::service

  Class['profile_postgresql::repo']
  -> Class['profile_postgresql::install']
  -> Class['profile_postgresql::service']
}
