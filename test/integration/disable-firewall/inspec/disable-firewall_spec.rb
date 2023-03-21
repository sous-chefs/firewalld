require_relative '../../helpers/spec_helper'

describe service('firewalld') do
  it { should_not be_installed }
  it { should_not be_enabled }
  it { should_not be_running }
end if firewalld?

describe service('iptables') do
  it { should_not be_installed }
  it { should_not be_enabled }
  it { should_not be_running }
end if iptables?
