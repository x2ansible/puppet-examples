#!/bin/bash
set -e

PUPPET_REPO="/puppet-repo"
PUPPET_ENVPATH="/etc/puppetlabs/code/environments"
PUPPET_ENV="${PUPPET_ENVPATH}/production"

echo "=== Installing Puppet 8 ==="
if ! command -v puppet &>/dev/null; then
  wget -O /tmp/puppet8-release-noble.deb https://apt.puppet.com/puppet8-release-noble.deb
  dpkg -i /tmp/puppet8-release-noble.deb
  rm -f /tmp/puppet8-release-noble.deb
  DEBIAN_FRONTEND=noninteractive apt-get update
  DEBIAN_FRONTEND=noninteractive apt-get install -y puppet-agent
fi

export PATH="/opt/puppetlabs/bin:/opt/puppetlabs/puppet/bin:${PATH}"

echo "=== Installing r10k ==="
/opt/puppetlabs/puppet/bin/gem install r10k --no-document

echo "=== Installing Forge modules via r10k ==="
cd "${PUPPET_REPO}"
r10k puppetfile install --puppetfile Puppetfile --moduledir modules

echo "=== Setting up Puppet environment ==="
rm -rf "${PUPPET_ENV}"
mkdir -p "${PUPPET_ENVPATH}"
ln -sfn "${PUPPET_REPO}" "${PUPPET_ENV}"

echo "=== Applying Puppet manifest ==="
set +e
puppet apply \
  --environmentpath="${PUPPET_ENVPATH}" \
  --environment=production \
  --detailed-exitcodes \
  "${PUPPET_ENV}/manifests/site.pp"
EXIT_CODE=$?
set -e

if [ $EXIT_CODE -eq 0 ]; then
  echo "Puppet applied successfully (no changes needed)"
elif [ $EXIT_CODE -eq 2 ]; then
  echo "Puppet applied successfully (changes made)"
else
  echo "Puppet apply FAILED (exit code ${EXIT_CODE})"
  exit 1
fi

echo ""
echo "=== Verifying services ==="
echo "--- HAProxy ---"
haproxy -c -f /etc/haproxy/haproxy.cfg -f /etc/haproxy/conf.d/
systemctl status haproxy --no-pager || true
echo ""
echo "--- Redis ---"
systemctl status redis-server --no-pager || true
echo ""
echo "=== Provisioning complete ==="
