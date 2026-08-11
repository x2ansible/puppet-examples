class role::app_server {
  include profile::base::base
  include profile::loadbalancer::haproxy
  include profile::app::stack
  include profile::cache::redis
}
