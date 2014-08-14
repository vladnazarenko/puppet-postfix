require 'spec_helper'

describe 'postfix::service', :type => :define do

  shared_examples "standard call" do |title,p,p_sub|
    p_def = {
      :private       => 'y',
      :unpriv        => 'y',
      :chroot        => 'y',
      :wakeup        => '11?',
      :maxproc       => '12',
      :command       => 'my_command',
    }

    p_for_us  = p_def.merge(p)
    p_sub     = p_def if p_sub.nil?
    p_sub     = p_def.merge(p_sub)

    let(:facts) {{
      :osfamily         => 'Debian',
      :operatingsystem  => 'Debian',
      :concat_basedir   => '/var/lib/puppet/concat',
    }}
    let(:title)  { title }
    let(:params) { p_for_us }

    if p[:mgmt] == "hard"
      it "should invoke HARD class correctly" do
        should contain_postfix__service__hard(title).with(p_sub)
      end
    else
      it "should invoke SOFT class correctly" do
        should contain_postfix__service__soft(title).with(p_sub)
      end
    end

  end


  context 'check hard service management' do
    it_behaves_like "standard call",
      "smtp", { :type => 'fifo', :mgmt => 'hard'}
  end

  context 'check soft service management' do
    it_behaves_like "standard call",
      "smtp", { :type => 'fifo', :mgmt => 'soft'}
  end

  context 'long service name' do
    it_behaves_like \
      "standard call",
      "long_service_name",
      { :type => 'fifo', :mgmt    => 'hard' },
      { :service => "long_service_name\n         " }
  end

  context 'long command name' do
    it_behaves_like \
      "standard call",
      "smtp",
      { :type => 'fifo', :mgmt    => 'hard',
        :command => "my super long command" },
      { :command => "my\n  super long command" }
  end

  context 'even longer command name' do
    it_behaves_like \
      "standard call",
      "smtp",
      { :type => 'fifo', :mgmt    => 'hard',
        :command => "my suuuuuuuuuuuper long mega command naaaaaaaaaaaaaame oh yeah what a command" },
      { :command => "my\n  suuuuuuuuuuuper long mega command naaaaaaaaaaaaaame oh yeah what\n  a command" }
  end

  context 'service.type notation' do
    it_behaves_like \
      "standard call",
      "smtp.fifo",
      { :mgmt    => 'hard' },
      { :service => 'smtp', :type => 'fifo' }
  end

end
