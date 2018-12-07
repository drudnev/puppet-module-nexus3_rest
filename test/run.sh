#!/usr/bin/env bash
BASE_PATH="/data/wandenberg-nexus3_rest"
echo "Installing Puppet module"
ln -f -s ${BASE_PATH}/test/common.yaml /etc/puppetlabs/code/environments/production/data/common.yaml
ln -f -s ${BASE_PATH}/test/nexus3_rest.conf /etc/puppetlabs/puppet/nexus3_rest.conf
ln -f -s ${BASE_PATH}/test/nexus3_rest.conf /etc/puppetlabs/puppet/nexus_rest.conf
cp -a ${BASE_PATH} /tmp/wandenberg-nexus3_rest

tar -zcf /tmp/wandenberg-nexus3_rest.tar.gz ${BASE_PATH}
puppet module install /tmp/wandenberg-nexus3_rest.tar.gz

# Lets give nexus some time to start
echo "Giving Nexus Time to Startup ..."
sleep 30

# Run puppet and show changes
puppet apply ${BASE_PATH}/test/site.pp --show_diff

# Validate Results :
puppet resource nexus3_repository --to_yaml > /tmp/nexus3_repository.yaml
puppet resource nexus3_repository_group --to_yaml  > /tmp/nexus3_repository_group.yaml


echo ""
echo "FINISHED CONFIGURATION"
echo ""

# 2nd run, should be noop
puppet apply ${BASE_PATH}/test/site.pp --show_diff --detailed-exitcodes
PUPPET_CODE=$?

# Diff puppet resources
diff -u ${BASE_PATH}/test/results/nexus3_repository.yaml /tmp/nexus3_repository.yaml
REPO=$?

diff -u ${BASE_PATH}/test/results/nexus3_repository_group.yaml /tmp/nexus3_repository_group.yaml
GROUP=$?

# Uncomment this if you want to keep puppet containter running
# docker exec -ti puppet_agent /bin/bash
#while true; do
#  sleep 5
#done

echo "Puppet exit code on the second run was ${PUPPET_CODE}"
echo ""
if [[ ${REPO} != 0 ]] || \
   [[ ${GROUP} != 0 ]] || \
   [[ ${PUPPET_CODE} != 0 ]] \
    ; then
  echo "ERROR: FAILED VALIDATION!"
  exit 1
fi
