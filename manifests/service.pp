#
#
# == Define: postfix::mastercf_service
#
# manages a postfix +master.cf+ service entry.
# Unless specifically given the parameters which can have a default value
# get this by using '-'.
#
#
# === Example
#
#   postfix::mastercf::service { 'smtp:'
#   type    => 'inet',
#   command   => 'smtpd'
#   }
#
# ... creates the line ...
#
#   ==========================================================================
#   service type  private unpriv  chroot  wakeup  maxproc command + args
#         (yes)   (yes)   (yes)   (never) (100)
#   ==========================================================================
#   smtp   inet  -    -     -     -     -     smtpd
#
# ... in +/etc/postfix/master.cf+ (without the comment of course).
#
define postfix::service (
  $ensure  = 'present',
  $service = $title,
  $type,
  $private = '-',
  $unpriv  = '-',
  $chroot  = '-',
  $wakeup  = '-',
  $maxproc = '-',
  $command = undef,
) {
  $def = 'postfix::service'


  include ::postfix


  if defined(Anchor["${service} ${type}"]) {
    fail("${def}: Service '${service}' of type '${type}' already defined!")
  }

  anchor { "${service} ${type}": }

  validate_re($ensure, '^(present|absent)$',
    "${def}: 'ensure' must be present/absent.")

  validate_re($type, '^(unix|fifo|inet|pass)$',
    "${def}: 'type' must be in unix/fifo/inet/pass.")

  validate_re($private, '^[yn-]$',
    "${def}: 'private' must be one of y/n/-.")

  validate_re($unpriv, '^[yn-]$',
    "${def}: 'unpriv' must be one of y/n/-.")

  validate_re($chroot, '^[yn-]$',
    "${def}: 'chroot' must be one of y/n/-.")

  validate_re($wakeup, '^([0-9]+\??|-)$',
    "${def}: 'wakeup' must be a '<number>', '<number>?' or '-'.")

  validate_re($maxproc, '^([0-9]+|-)$',
    "${def}: 'maxproc' must be a number or '-'.")

  if $ensure == 'present' and $command == undef {
    fail("${def}: you must pass \$command for \$ensure=>'present'.")
  }

  if $ensure == 'present' {
    augeas { "${title}_add":
      context => '/files/etc/postfix/master.cf',
      changes => [
        "defnode mynode /files/etc/postfix/master.cf/${service}[type = '${type}'] ''",
        "set \$mynode/type '${type}'",
        "set \$mynode/private '${private}'",
        "set \$mynode/unprivileged '${unpriv}'",
        "set \$mynode/chroot '${chroot}'",
        "set \$mynode/wakeup '${wakeup}'",
        "set \$mynode/limit '${maxproc}'",
        "set \$mynode/command '${command}'",
      ],
      notify  => Service['postfix'],
    }
  } else {
    augeas { "${title}_remove":
      context => '/files/etc/postfix/master.cf',
      changes => "rm ${service}[type='${type}']",
      notify  => Service['postfix'],
    }

  }

}
