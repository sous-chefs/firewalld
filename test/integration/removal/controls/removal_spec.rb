# frozen_string_literal: true

case input('removal_type')
when 'dbus_delete'
  {
    'policies' => %w(ptest pminimal),
    'zones' => %w(ztest ztest2),
    'services' => %w(ssh2 minimal-service),
    'ipsets' => %w(example-ips single-ip),
    'icmptypes' => %w(rick-rolled minimal-icmptype),
    'helpers' => %w(example-helper minimal-helper),
  }.each do |type, names|
    describe command("firewall-cmd --permanent --get-#{type}") do
      its('exit_status') { should eq 0 }
      names.each { |name| its('stdout') { should_not match(/\b#{Regexp.escape(name)}\b/) } }
    end
  end
when 'nftables_delete'
  describe package('nftables') do
    it { should_not be_installed }
  end
  describe file(os.debian? ? '/etc/nftables.conf' : '/etc/sysconfig/nftables.conf') do
    it { should_not exist }
  end
else
  if os.debian?
    describe package('ufw') do
      it { should_not be_installed }
    end
    describe file('/etc/default/ufw-chef.rules') do
      it { should_not exist }
    end
  elsif os.name == 'amazon' && input('removal_backend') != 'iptables'
    describe package('firewalld') do
      it { should_not be_installed }
    end
    describe file('/etc/sysconfig/firewalld-chef.rules') do
      it { should_not exist }
    end
  elsif input('removal_backend') == 'iptables' || os.redhat?
    describe package('iptables-services') do
      it { should_not be_installed }
    end
    %w(iptables ip6tables).each do |family|
      describe file("/etc/sysconfig/#{family}") do
        it { should_not exist }
      end
    end
  end
end
