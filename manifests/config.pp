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
  $mgmt   = $::postfix::configfile_management,
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

  case $mgmt {
    'hard': {
      ::postfix::config::hard { $title:
        ensure  => $ensure,
        value   => $value,
      }
    }
    default: {
      ::postfix::config::soft { $title:
        ensure  => $ensure,
        value   => $value,
      }
    }
  }

}
