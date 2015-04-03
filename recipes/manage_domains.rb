include_recipe "sslmate::default"
include_recipe "sslmate::dns"

# Install helper scripts for each domain to buy, install, and handle
# auto-renewal in cron.
node[:sslmate][:domains].each do |domain|
  # Set default values.
  domain_attrs = Chef::Mash.new({
    :reissue_days => 30,
    :keep_previous_certs => 1,
  }).merge(domain)

  if(domain_attrs[:elbs])
    domain_attrs[:elbs].map! do |elb|
      Chef::Mash.new({
        :port => 443,
      }).merge(elb)
    end
  end

  template "#{node[:sslmate][:prefix]}/sbin/sslmate_#{domain[:host]}_buy" do
    source "cert_buy.erb"
    variables(:domain => domain_attrs)
    owner "root"
    group "root"
    mode "0755"
  end

  template "#{node[:sslmate][:prefix]}/sbin/sslmate_#{domain[:host]}_install" do
    source "cert_install.erb"
    variables(:domain => domain_attrs)
    owner "root"
    group "root"
    mode "0755"
  end

  template "/etc/cron.daily/sslmate_#{domain[:host]}_auto_renew" do
    source "cert_auto_renew.erb"
    variables(:domain => domain_attrs)
    owner "root"
    group "root"
    mode "0755"
  end
end
