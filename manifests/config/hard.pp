#
# == Definition: postfix::config::hard
#
# INTERNAL CLASS, do NOT use directly.
# Please see +::postfix::config+ for documentation.
#
#
define postfix::config::hard (
  $ensure = 'present',
  $value  = undef,
) {
  $def = 'postfix::config::hard'

  if $ensure =~ /^(absent|blank)$/ {
    fail("${def}: \$ensure can only be 'present' with 'hard' config file management!")
  }

  $use_line = sprintf("%-35s = %s\n", $title, $value)

  concat::fragment { "postfix_maincf_${title}":
    target  => '/etc/postfix/main.cf',
    content => $use_line,
    order   => $title,
  }

}
