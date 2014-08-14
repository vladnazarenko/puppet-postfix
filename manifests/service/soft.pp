#
#
# == Define: postfix::service::soft
#
# INTERNAL CLASS, do NOT use directly.
# Please see +::postfix::service+ for documentation.
#
#
define postfix::service::soft (
  $ensure         = 'present',
  $service        = $title,
  $type,
  $private        = '-',
  $unpriv         = '-',
  $chroot         = '-',
  $wakeup         = '-',
  $maxproc        = '-',
  $command        = undef,
) {
  $def = 'postfix::service::soft'


  include ::postfix


  if is_array($command) {
    $use_command = inline_template('<%=
      "#{@command.shift}\n  #{@command.join("\n  ")}"
    %>')
  } else {
    $use_command = $command
  }

  if $ensure == 'present' {
    augeas { "postfix_mastercf_${title}_add":
      context => '/files/etc/postfix/master.cf',
      lens    => 'Postfix_Master.lns',
      changes => [
        "defnode mynode /files/etc/postfix/master.cf/${service}[type = '${type}'] ''",
        "set \$mynode/type '${type}'",
        "set \$mynode/private '${private}'",
        "set \$mynode/unprivileged '${unpriv}'",
        "set \$mynode/chroot '${chroot}'",
        "set \$mynode/wakeup '${wakeup}'",
        "set \$mynode/limit '${maxproc}'",
        "set \$mynode/command '${use_command}'",
      ],
      notify  => Service['postfix'],
    }
  } else {
    augeas { "postfix_mastercf_${title}_remove":
      context => '/files/etc/postfix/master.cf',
      lens    => 'Postfix_Master.lns',
      changes => "rm ${service}[type='${type}']",
      notify  => Service['postfix'],
    }

  }

}
