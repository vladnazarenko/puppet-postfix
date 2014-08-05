require 'spec_helper'

describe 'postfix' do
  context 'default use' do
    let(:facts) {{
      :osfamily         => 'Debian',
      :operatingsystem  => 'Debian',
    }}

    it "should contain postfix package" do
      should contain_package('postfix')
    end
    it "should contain postfix service" do
      should contain_service('postfix')
    end
    it "should save the config files" do
      should contain_exec('save postfix main.cf')
      should contain_exec('save postfix master.cf')
    end
  end

end
