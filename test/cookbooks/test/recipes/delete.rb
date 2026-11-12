# frozen_string_literal: true

firewall 'default' do
  backend node.dig('firewalld_test', 'backend').to_sym if node.dig('firewalld_test', 'backend')
  action :delete
end
