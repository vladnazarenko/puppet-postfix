#
#
# == Define: postfix::service_line
#
# Manages a postfix +master.cf+ service entry, just like +postfix::service+.
# But here you can give the actual line which is parsed and passed to
# +postfix::service+, which takes much less text space sometimes.
#
#
# === Parameters
#
# [*title*]
#   The title must conform to the +word1.word2+ notation.
#
# [*ensure*]
#   Optional, defaults to +present+. Can also be 'absent' and 'blank', but
#   only for +soft+ configfile management.
#
# [*line*]
#   Required. Must contain everything except type and service.
#
#
# === Examples
#
#   postfix::mastercf::service_line { 'smtp.inet':
#     line => 'y n - - - smtp_command with=flags'
#   }
#
# Those declarations will result in the following +master.cf+ lines:
#
#   ==========================================================================
#   service type  private unpriv  chroot  wakeup  maxproc command + args
#         (yes)   (yes)   (yes)   (never) (100)
#   ==========================================================================
#   smtp    inet  y       n       -       -       -       smtp_comand with=flags
#
#
define postfix::service_line (
  $ensure  = 'present',
  $line,
) {
  $def = 'postfix::service'

  $line2  = regsubst(strip($line), ' +', ' ', 'MG')
  $splits = split($line2, ' ')

  $private     = $splits[0]
  $unpriv      = $splits[1]
  $chroot      = $splits[2]
  $wakeup      = $splits[3]
  $maxproc     = $splits[4]
  $command     = inline_template('<%= @splits[5..-1].join(" ") %>')

  ::postfix::service { $title:
    ensure  => $ensure,
    private => $private,
    unpriv  => $unpriv,
    chroot  => $chroot,
    wakeup  => $wakeup,
    maxproc => $maxproc,
    command => $command,
  }

}
