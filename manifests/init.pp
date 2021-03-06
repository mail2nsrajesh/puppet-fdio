# == Class: fdio
#
# Installs vpp and configures /etc/vpp/startup.conf
#
# === Parameters:
# [*repo_branch*]
#   (optional) fd.io repo branch.
#   Valid values are 'release', 'master' and stable branch like 'stable.1609'.
#   Defaults to 'release'.
#
# [*vpp_dpdk_support*]
#   (optional) Enable DPDK support for VPP
#   Defaults to true
#
# [*vpp_dpdk_devs*]
#   (optional) Array of PCI addresses to bind to vpp.
#   Defaults to undef.
#
# [*vpp_dpdk_uio_driver*]
#   (optional) VPP DPDK UIO driver type.
#   Defaults to 'uio_pci_generic'
#
# [*vpp_dpdk_dev_default_options*]
#   (optional) VPP interface default options configuration.
#   This will configure dev default {options}. It should be a string
#   containing all of the desired options.
#   Example: 'vlan-strip-offload on num-rx-queues 3'
#   Default to undef.
#
# [*vpp_cpu_main_core*]
#   (optional) VPP main thread pinning core.
#   Defaults to undef (no pinning)
#
# [*vpp_cpu_corelist_workers*]
#   (optional) Comma separated list of cores for VPP worker thread pinning in
#   string format.
#   Example: '2,3'.
#   Defaults to undef (no pinning)
#
# [*copy_kernel_nic_ip*]
#   (optional) Configures VPP interface with IP settings found on its corresponding kernel NIC.
#   Defaults to true
#
class fdio (
  $repo_branch                  = $::fdio::params::repo_branch,
  $vpp_dpdk_support             = $::fdio::params::vpp_dpdk_support,
  $vpp_dpdk_devs                = $::fdio::params::vpp_dpdk_devs,
  $vpp_dpdk_uio_driver          = $::fdio::params::vpp_dpdk_uio_driver,
  $vpp_dpdk_dev_default_options = $::fdio::params::vpp_dpdk_dev_default_options,
  $vpp_cpu_main_core            = $::fdio::params::vpp_cpu_main_core,
  $vpp_cpu_corelist_workers     = $::fdio::params::vpp_cpu_corelist_workers,
  $copy_kernel_nic_ip           = $::fdio::params::copy_kernel_nic_ip,
) inherits ::fdio::params {

  validate_array($vpp_dpdk_devs)

  # Validate OS family
  case $::osfamily {
    'RedHat': {}
    'Debian': {
        warning('Debian has limited support, is less stable, less tested.')
    }
    default: {
        fail("Unsupported OS family: ${::osfamily}")
    }
  }

  # Validate OS
  case $::operatingsystem {
    'centos', 'redhat': {
      if $::operatingsystemmajrelease != '7' {
        # RHEL/CentOS versions < 7 not supported as they lack systemd
        fail("Unsupported OS: ${::operatingsystem} ${::operatingsystemmajrelease}")
      }
    }
    'fedora': {
      # Fedora distros < 23 are EOL as of 2016-07-19
      # https://fedoraproject.org/wiki/End_of_life
      if $::operatingsystemmajrelease < '23' {
        fail("Unsupported OS: ${::operatingsystem} ${::operatingsystemmajrelease}")
      }
    }
    'ubuntu': {
      if $::operatingsystemmajrelease != '16.04' {
        fail("Unsupported OS: ${::operatingsystem} ${::operatingsystemmajrelease}")
      }
    }
    default: {
      fail("Unsupported OS: ${::operatingsystem}")
    }
  }

  class { '::fdio::install': } ->
  class { '::fdio::config': } ~>
  class { '::fdio::service': } ->
  Class['::fdio']

}
