#
#
# == Define: postfix::service::hard
#
# INTERNAL CLASS, do NOT use directly.
# Please see +::postfix::service+ for documentation.
#
#
define postfix::service::hard (
  $ensure         = 'present',
  $service        = $title,
  $type,
  $private        = '-',
  $unpriv         = '-',
  $chroot         = '-',
  $wakeup         = '-',
  $maxproc        = '-',
  $command,
) {
  $def = 'postfix::service::hard'

  $use_order  = regsubst("01_${service}_${type}", '[^a-zA-Z0-9]+', '_', 'MG')
  $use_line   = sprintf("%-9s %-5s %-7s %-7s %-7s %-7s %-7s %s\n",
    $service, $type, $private, $unpriv, $chroot, $wakeup,
    $maxproc, $command)

  concat::fragment { "postfix_mastercf_${title}":
    target  => '/etc/postfix/master.cf',
    content => $use_line,
    order   => $use_order,
  }

}
