# Configure the PGDG apt repository for a pinned PostgreSQL major version.
class profile_app_stack::postgres_repo {

  include apt

  apt::source { 'pgdg':
    location => lookup('profile_app_stack::postgres_repo_location'),
    release  => lookup('profile_app_stack::postgres_repo_release'),
    repos    => 'main',
    key      => {
      id     => lookup('profile_app_stack::postgres_repo_key_id'),
      source => lookup('profile_app_stack::postgres_repo_key_source'),
    },
  }
}
