#
#
# == Class: postfix::prepare_hard_config_management
#
# Prepares the 'hard' management of the config files. Internal class, do not
# use!
#
#
class postfix::prepare_hard_config_management {

  concat { ['/etc/postfix/main.cf', '/etc/postfix/master.cf']:
    ensure  => 'present',
    force   => true,
    warn    => true,
    replace => true,
    backup  => false,
    notify  => Service['postfix'],
  }

  concat::fragment { 'postfix master.cf header':
    target  => '/etc/postfix/master.cf',
    source  => 'puppet:///modules/postfix/postfix_master_header',
    order   => '00',
  }

}
