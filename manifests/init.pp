#
# == Class: postfix
#
# This class sets up the postfix daemon as it is configured by the
# distribution. All configuration must be done outside of here.
#
#
class postfix (
  $configfile_management = $::postfix::params::configfile_management,
) inherits ::postfix::params {
  $cls = '::postfix'


  # validation

  validate_re($configfile_management, '^(soft|hard)$',
    "${cls}: \$configfile_management must be one of 'soft'/'hard'.")


  # package

  package { 'postfix':
    ensure => installed,
  } ->


  # files

  exec { 'save postfix main.cf':
    command => 'cp /etc/postfix/main.cf /etc/postfix/main.cf.orig',
    path    => [ '/usr/bin', '/bin', ],
    unless  => 'test -f /etc/postfix/main.cf.orig',
  } ->
  exec { 'save postfix master.cf':
    command => 'cp /etc/postfix/master.cf /etc/postfix/master.cf.orig',
    path    => [ '/usr/bin', '/bin', ],
    unless  => 'test -f /etc/postfix/master.cf.orig',
  } ->
  # make sure this is the first thing we do.
  Postfix::Config<| |> ->
  Postfix::Service<| |>

  if $configfile_management == 'hard' {
    include prepare_hard_config_management
    Exec['save postfix master.cf'] ->
    Class['prepare_hard_config_management']
  }


  # triggers

  Mailalias<| |> ~>
  exec { 'newaliases':
    command     => '/usr/bin/newaliases',
    refreshonly => true,
  }


  # service

  service { 'postfix':
    ensure    => running,
    enable    => true,
    hasstatus => true,
    restart   => '/etc/init.d/postfix reload',
  }


  # order with "hash"

  Class['postfix'] ->
  Postfix::Hash <| |>

}
