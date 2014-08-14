require 'spec_helper'

describe 'postfix::service_line' do

  shared_examples "call" do |title,p,p_sub|
    p_def = {
      :private       => 'y',
      :unpriv        => 'y',
      :chroot        => 'y',
      :wakeup        => '12?',
      :maxproc       => '11',
      :command       => 'my_command',
    }
    p_sub = p_def if p_sub.nil?
    p_sub = p_def.merge(p_sub)

    let(:title)  { title }
    let(:params) { p }
    let(:facts)  {{
      :osfamily         => 'Debian',
      :operatingsystem  => 'Debian',
      :concat_basedir   => '/var/lib/puppet/concat',
    }}

    it "should call postfix::service with correct pararmeters" do
      should contain_postfix__service(title).with(p_sub)
    end
  end


  context 'default use' do
    it_behaves_like "call" ,"smtp.inet",
      { :line => "   y   y y  12?    11 my_command" }
  end

  context 'multi-word command' do
    it_behaves_like "call" ,"smtp.inet",
      { :line => "   y   y y  12?    11 my_command is not finished" }
      { :command => "my command is not finished" }
  end

end
