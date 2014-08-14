require 'spec_helper'

describe 'postfix::service::soft' do
  context 'default use' do
    let(:facts) {{
      :osfamily         => 'Debian',
      :operatingsystem  => 'Debian',
    }}
    let(:title) { "smtp" }
    let(:params){{
      :type          => 'fifo',
      :private       => 'y',
      :unpriv        => 'y',
      :chroot        => 'y',
      :wakeup        => '12?',
      :maxproc       => '11',
      :command       => 'my_command',
    }}

    it "should use parameters correctly" do
      should contain_augeas('postfix_mastercf_smtp_add').with({
        :changes => [
          "defnode mynode /files/etc/postfix/master.cf/smtp[type = 'fifo'] ''",
          "set \$mynode/type 'fifo'",
          "set \$mynode/private 'y'",
          "set \$mynode/unprivileged 'y'",
          "set \$mynode/chroot 'y'",
          "set \$mynode/wakeup '12?'",
          "set \$mynode/limit '11'",
          "set \$mynode/command 'my_command'",
        ]
      })
    end
  end

  context 'with command given as array' do
    let(:facts) {{
      :osfamily         => 'Debian',
      :operatingsystem  => 'Debian',
    }}
    let(:title) { "smtp" }
    let(:params){{
      :type          => 'fifo',
      :private       => 'y',
      :unpriv        => 'y',
      :chroot        => 'y',
      :wakeup        => '12?',
      :maxproc       => '11',
      :command       => [ 'my', 'command', 'here' ],
    }}

    it "should use parameters correctly" do
      should contain_augeas('postfix_mastercf_smtp_add').with({
        :changes => [
          "defnode mynode /files/etc/postfix/master.cf/smtp[type = 'fifo'] ''",
          "set \$mynode/type 'fifo'",
          "set \$mynode/private 'y'",
          "set \$mynode/unprivileged 'y'",
          "set \$mynode/chroot 'y'",
          "set \$mynode/wakeup '12?'",
          "set \$mynode/limit '11'",
          "set \$mynode/command 'my\n  command\n  here'",
        ]
      })
    end
  end

end
