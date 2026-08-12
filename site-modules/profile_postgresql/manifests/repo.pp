class profile_postgresql::repo {

  include apt

  apt::source { 'pgdg':
    location => lookup('profile_postgresql::repo_location'),
    release  => lookup('profile_postgresql::repo_release'),
    repos    => 'main',
    key      => {
      id     => lookup('profile_postgresql::repo_key_id'),
      source => lookup('profile_postgresql::repo_key_source'),
    },
  }
}
