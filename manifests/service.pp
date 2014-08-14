#
#
# == Define: postfix::service
#
# manages a postfix +master.cf+ service entry.
# Unless specifically given the parameters which can have a default value
# get this by using '-'.
#
#
# === Parameters
#
# [*ensure*]
#   Optional, defaults to +present+. Can also be 'absent' and 'blank', but
#   only for +soft+ configfile management.
#
# [*service*]
#   Optional and namevar. See +type+ for alternate notation possibilities.
#   Put in the 1st column of the +master.cf+ row.
#
# [*type*]
#   Required, unless the title has the form "word1.word2". In that case the
#   +$service+ is set to +word1+, and the +$type+ is set to +word2+.
#   Put in the 2nd column of the +master.cf+ row.
#
# [*private*]
#   Optional, defaults to +-+.
#   Put in the 3rd column of the +master.cf+ row.
#
# [*unpriv*]
#   Optional, defaults to +-+.
#   Put in the 4th column of the +master.cf+ row.
#
# [*chroot*]
#   Optional, defaults to +-+.
#   Put in the 5th column of the +master.cf+ row.
#
# [*wakeup*]
#   Optional, defaults to +-+.
#   Put in the 6th column of the +master.cf+ row.
#
# [*maxproc*]
#   Optional, defaults to +-+.
#   Put in the 7th column of the +master.cf+ row.
#
# [*command*]
#   Required.
#   Put in the last column of the +master.cf+ row.
#
# [*mgmt*]
#   Internal variable, never use.
#
#
# === Examples
#
#   postfix::mastercf::service { 'smtp':
#   type    => 'inet',
#   command   => 'smtpd'
#   }
#
#   # or specify service and type in one
#   postfix::mastercf::service { 'smtp.fifo':
#   command   => 'wohoo_smtp'
#   }
#
# Those declarations will result in the following +master.cf+ lines:
#
#   ==========================================================================
#   service type  private unpriv  chroot  wakeup  maxproc command + args
#         (yes)   (yes)   (yes)   (never) (100)
#   ==========================================================================
#   smtp   inet  -    -     -     -     -     smtpd
#   smtp   fifo  -    -     -     -     -     wohoo_smtp
#
#
define postfix::service (
  $ensure  = 'present',
  $service = undef,
  $type    = undef,
  $private = '-',
  $unpriv  = '-',
  $chroot  = '-',
  $wakeup  = '-',
  $maxproc = '-',
  $command = undef,
  $mgmt    = $::postfix::configfile_management,
) {
  $def = 'postfix::service'

  include ::postfix

  # convenience - use "inet.fifo" notation to declare both service and type
  # at the same time. if you do this you may NOT set $service or $type
  # explicitly
  if $title =~ /[^\.]+\.[^\.]+/ {
    if $service != undef or $type != undef {
      fail("${def}: when using service.type notation you may not set \$service or \$type explicitly!")
    }
    $splits       = split($title, '\.')
    $tmp_service  = $splits[0]
    $use_type     = $splits[1]
  }
  else {
    $tmp_service = $service ? {
      undef   => $title,
      default => $service,
    }
    if $type == undef {
      fail("${def}: you have to set \$type!")
    }
    $use_type = $type
  }


  # validation

  if defined(Anchor["${tmp_service} ${use_type}"]) {
    fail("${def}: Service '${tmp_service}' of type '${use_type}' already defined!")
  }

  anchor { "${tmp_service} ${use_type}": }

  validate_re($ensure, '^(present|absent)$',
    "${def}: 'ensure' must be present/absent.")

  validate_re($use_type, '^(unix|fifo|inet|pass)$',
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


  # make things a bit more readable. cosmetic only.

  if is_array($command) {
    $use_command = inline_template('<%=
      "#{@command.shift}\n  #{@command.join("\n  ")}"
    %>')
  } else {
    # just make it a bit nicer to read ...
    $use_command = inline_template('<%=
      words = @command.gsub(/ +/, " ").split(" ")
      res = words.shift
      tmp = ""
      i = 0
      while words.length() > 0
        tmp += words.shift() + " "
        if tmp.length > 60 or words.length == 0
          res += "\n  "+tmp.strip()
          i = 0
          tmp = ""
        end
      end
      res
    %>')
  }


  $use_service = inline_template('<%=
    s = @tmp_service.to_s.strip()       # could be fixnum - e.g. 26
    s.length() > 9 ? "#{s}\n         " : s
  %>')


  case $mgmt {
    'hard': {
      ::postfix::service::hard { $title:
        ensure  => $ensure,
        service => $use_service,
        type    => $use_type,
        private => $private,
        unpriv  => $unpriv,
        chroot  => $chroot,
        wakeup  => $wakeup,
        maxproc => $maxproc,
        command => $use_command,
      }
    }
    default: {
      ::postfix::service::soft { $title:
        ensure  => $ensure,
        service => $use_service,
        type    => $use_type,
        private => $private,
        unpriv  => $unpriv,
        chroot  => $chroot,
        wakeup  => $wakeup,
        maxproc => $maxproc,
        command => $use_command,
      }
    }
  }

}
