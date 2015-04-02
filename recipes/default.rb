include_recipe "git"
include_recipe "perl"

dependencies = value_for_platform_family({
  ["rhel", "fedora"] => [
    "perl-URI",
    "perl-TermReadKey",
    "perl-JSON",
    "perl-WWW-Curl",
  ],
  ["ubuntu", "debian"] => [
    "liburi-perl",
    "libterm-readkey-perl",
    "libjson-perl",
    "libwww-curl-perl",
  ],
  "default" => [],
})

dependencies.each do |package_name|
  package package_name
end

bash "install_sslmate" do
  cwd "#{Chef::Config[:file_cache_path]}/sslmate"
  code <<-EOS
    make install PREFIX=#{node[:sslmate][:prefix]}
  EOS
  action :nothing
end

git "#{Chef::Config[:file_cache_path]}/sslmate" do
  repository node[:sslmate][:git_repository]
  revision node[:sslmate][:git_revision]
  action :sync
  notifies :run, "bash[install_sslmate]", :immediately
end
