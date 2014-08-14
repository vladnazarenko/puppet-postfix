#
# == Definition: postfix::config::soft
#
# INTERNAL CLASS, do NOT use directly.
# Please see +::postfix::config+ for documentation.
#
#
define postfix::config::soft (
  $ensure = 'present',
  $value  = undef,
) {
  $def = 'postfix::config::soft'

  case $ensure {
    present: {
      augeas { "set postfix '${name}' to '${value}'":
        changes => "set ${name} '${value}'",
        incl    => '/etc/postfix/main.cf',
        lens    => 'Postfix_Main.lns',
        require => Package['postfix'],
        notify  => Service['postfix'],
      }
    }
    absent: {
      augeas { "rm postfix '${name}'":
        changes => "rm ${name}",
        incl    => '/etc/postfix/main.cf',
        lens    => 'Postfix_Main.lns',
        require => Package['postfix'],
        notify  => Service['postfix'],
      }
    }
    blank: {
      augeas { "blank postfix '${name}'":
        changes => "clear ${name}",
        incl    => '/etc/postfix/main.cf',
        lens    => 'Postfix_Main.lns',
        require => Package['postfix'],
        notify  => Service['postfix'],
      }
    }
    default: {}     # satisfy stupid linter.
  }

}
