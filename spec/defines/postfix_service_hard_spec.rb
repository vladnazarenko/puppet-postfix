require 'spec_helper'

describe 'postfix::service::hard' do
  shared_examples "hard_call" do |srv,p,line_parts,order|
    srv         = 'smtp'  if srv.nil?
    p           = {}      if p.nil?
    line_parts  = {}      if line_parts.nil?
    p = {
      :service       => srv,
      :type          => 'fifo',
      :private       => 'y',
      :unpriv        => 'y',
      :chroot        => 'y',
      :wakeup        => '12?',
      :maxproc       => '11',
      :command       => 'my_command',
    }.merge(p)
    line_parts = {
      :service => format("%-9s",  p[:service]),
      :type    => format("%-5s",  p[:type   ]),
      :private => format("%-7s",  p[:private]),
      :unpriv  => format("%-7s",  p[:unpriv ]),
      :chroot  => format("%-7s",  p[:chroot ]),
      :wakeup  => format("%-7s",  p[:wakeup ]),
      :maxproc => format("%-7s",  p[:maxproc]),
      :command => format("%s",    p[:command]),
    }.merge(line_parts)
    order_default = "01_#{p[:service]}_#{p[:type]}"
    order = order_default if order.nil?

    line = ""
    [:service, :type, :private, :unpriv,
    :chroot, :wakeup, :maxproc, :command].each do |p|
      line += line_parts[p] + " "
    end
    line = line.strip() + "\n"

    let(:title)  { 'smtp' }
    let(:params) { p }
    let(:facts)  {{
      :osfamily         => 'Debian',
      :operatingsystem  => 'Debian',
      :concat_basedir   => '/var/lib/puppet/concat',
    }}

    it "should call concat::fragment with correct pararmeters" do
      should contain_concat__fragment('postfix_mastercf_smtp').with({
        :target   => '/etc/postfix/master.cf',
        :content  => line,
        :order    => order,
      })
    end
  end


  context 'default use' do
    it_behaves_like "hard_call"
  end

  context 'multiline service' do
    it_behaves_like "hard_call", "smtp",
      { :service => "my_long_service\n          "},
      { :service => "my_long_service\n          "},
      "01_my_long_service_fifo"
  end

end
