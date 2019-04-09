#!/bin/bash

# This assumes that the user
# OnBoard/Margay will run-as
# already exists in the system and can sudo,
# and software is copied / placed in the relevant directory with proper
# ownership/permissions. This script takes
# control from there.
# Another script may be implemented for that very initial
# bootstrap instead, and will likely not be used by Vagrant but only for
# deployment on real hardware or "naked" VMs.

# echo $* # DEBUG

PROJECT_ROOT=${1:-'.'}
APP_USER=${2:-'onboard'}

install_conffiles() {
	# TODO: /etc/default/margay to set OnBoard user!
	install -bvC -m 755 doc/sysadm/examples/etc/init.d/onboard 		/etc/init.d/
	install -bvC -m 644 doc/sysadm/examples/etc/dnsmasq.conf 		/etc/
	install -bvC -m 644 doc/sysadm/examples/etc/sysctl.conf		    /etc/
}

bundle_without_all_opts() {
	# Avoid --without (empty)
	without_opt=''
	groups=''
	for mod in `ls $PROJECT_ROOT/modules` ; do
		if [ -f $PROJECT_ROOT/modules/$mod/Gemfile ]; then
			without_opt='--without'
			groups="$groups $mod"
		fi
	done
	echo "$without_opt $groups" | xargs
}

disable_app_modules() {
	for dir in $PROJECT_ROOT/modules/* ; do
		if [ ! -f $dir/.enable ]; then
			file=$dir/.disable
			touch $file
			chown $APP_USER $file
		fi
	done
}

disable_dhcpcd_master() {
	# Even if no interface is configured with dhcp in /etc/network/interfaces,
	# dhcpcd is a system(d) service, that starts as just "dhcpcd" (master mode)
	# which is incompatible with onboard detection and control.
	if (systemctl status dhcpcd > /dev/null); then
		systemctl disable dhcpcd
	fi
}


export DEBIAN_FRONTEND=noninteractive

cd $PROJECT_ROOT

apt-get update
apt-get -y upgrade
# TODO: lighttpd removed: NGINX!
apt-get -y install ruby ruby-bundler ruby-dev ruby-erubis ruby-rack ruby-rack-protection ruby-locale ruby-facets sudo iproute iptables bridge-utils pciutils dhcpcd5 dnsmasq resolvconf locales ifrename build-essential ca-certificates ntp psmisc

install_conffiles

su - $APP_USER -c "
	cd $PROJECT_ROOT
	# Module names are also Gemfile groups
	echo Running: bundle install $(bundle_without_all_opts) \# This may take some time...
	bundle install $(bundle_without_all_opts)
"

modprobe nf_conntrack_ipv4
modprobe nf_conntrack_ipv6
service procps restart

# TODO: /etc/default/margay to set OnBoard user!
# systemctl enable onboard

disable_app_modules

disable_dhcpcd_master

if [ ! -f /etc/default/margay ]; then

	cat > /etc/default/margay <<EOF
# Automatically generated by setup.sh
APP_USER=$APP_USER
PROJECT_ROOT=$PROJECT_ROOT
EOF

fi