require_relative '../../helpers/spec_helper'

describe service('firewalld') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end if firewalld?

describe service('iptables') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end if iptables?
