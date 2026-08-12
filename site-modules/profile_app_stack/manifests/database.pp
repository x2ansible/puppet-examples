# Database provisioning — delegates PostgreSQL install to profile_postgresql.
class profile_app_stack::database {

  if $profile_app_stack::db_host == 'localhost' {
    include profile_postgresql

    exec { 'create_db_user':
      command => "sudo -u postgres psql -c \"CREATE USER ${profile_app_stack::db_user} WITH PASSWORD '${profile_app_stack::db_password}';\"",
      unless  => "sudo -u postgres psql -tAc \"SELECT 1 FROM pg_roles WHERE rolname='${profile_app_stack::db_user}'\" | grep -q 1",
      path    => ['/usr/bin', '/bin'],
      require => Class['profile_postgresql::service'],
    }

    exec { 'create_database':
      command => "sudo -u postgres psql -c \"CREATE DATABASE ${profile_app_stack::db_name} OWNER ${profile_app_stack::db_user};\"",
      unless  => "sudo -u postgres psql -tAc \"SELECT 1 FROM pg_catalog.pg_database WHERE datname='${profile_app_stack::db_name}'\" | grep -q 1",
      path    => ['/usr/bin', '/bin'],
      require => Exec['create_db_user'],
    }

    exec { 'grant_db_privileges':
      command => "sudo -u postgres psql -c \"GRANT ALL PRIVILEGES ON DATABASE ${profile_app_stack::db_name} TO ${profile_app_stack::db_user};\"",
      unless  => "sudo -u postgres psql -tAc \"SELECT has_database_privilege('${profile_app_stack::db_user}', '${profile_app_stack::db_name}', 'CREATE')\" | grep -q t",
      path    => ['/usr/bin', '/bin'],
      require => Exec['create_database'],
    }
  }

  file { '/usr/local/bin/db-backup.sh':
    ensure => file,
    source => 'puppet:///modules/profile_app_stack/backup.sh',
    owner  => 'root',
    group  => $profile_app_stack::app_group,
    mode   => '0750',
  }

  cron { 'database_backup':
    command => "/usr/local/bin/db-backup.sh ${profile_app_stack::db_name} ${profile_app_stack::db_host}",
    user    => 'root',
    hour    => 2,
    minute  => 30,
  }
}
