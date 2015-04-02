include_recipe "sslmate::default"

# Install the additional dependencies for the beta feature to verify domains
# via DNS: https://github.com/SSLMate/sslmate/issues/9
include_recipe "awscli"
include_recipe "python"
python_pip "boto"

directory "/etc/sslmate" do
  owner "root"
  group "root"
  mode "0755"
end

template "/etc/sslmate/dns_approval_map" do
  source "dns_approval_map.erb"
  owner "root"
  group "root"
  mode "0600"
end

template "/etc/sslmate.conf" do
  source "sslmate.conf.erb"
  owner "root"
  group "root"
  mode "0644"
end
