#
# == Definition: postfix::config
#
# Uses Augeas to add/alter/remove options in postfix main
# configuation file (/etc/postfix/main.cf).
#
# TODO: make this a type with an Augeas and a postconf providers.
#
# === Parameters
#
# [*name*]   - name of the parameter.
# [*ensure*] - present/absent/blank. defaults to present.
# [*value*]  - value of the parameter.
#
# === Requires
#
# - Class["postfix"]
#
# === Examples
#
#   postfix::config { 'smtp_use_tls':
#     ensure => 'present',
#     value  => 'yes',
#   }
#
#   postfix::config { 'relayhost':
#     ensure => 'blank',
#   }
#
define postfix::config (
  $ensure = 'present',
  $value  = undef,
) {

  validate_re($ensure, '^(present|absent|blank)$',
    "\$ensure must be either 'present', 'absent' or 'blank', got '${ensure}'")

  if ($ensure == 'present') {
    validate_string($value)
    validate_re($value, '^.+$',
      '$value can not be empty if ensure = present')
  }

  if (!defined(Class['postfix'])) {
    fail 'You must define class postfix before using postfix::config!'
  }

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
