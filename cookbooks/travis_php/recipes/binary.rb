include_recipe 'bison'
include_recipe 'libreadline'

include_recipe 'travis_phpenv'
include_recipe 'travis_phpbuild'

unpack_dir = File.join(node['travis_build_environment']['home'], '.phpenv', 'versions')

node['travis_php']['binaries'].each do |php|
  local_archive = File.join(Chef::Config[:file_cache_path], "php-#{php[:version]}.tar.bz2")

  remote_file local_archive do
    source "https://s3.amazonaws.com/travis-php-archives/php-#{php[:version]}.tar.bz2"
    checksum php[:checksum]
    only_if { node['platform'] == 'ubuntu' && node['platform_version'] == '12.04' }
  end

  bash "Expand PHP #{php[:version]} archive" do
    user node['travis_build_environment']['user']
    group node['travis_build_environment']['group']

    code "tar -xjf #{local_archive} --directory #{unpack_dir}"

    not_if { File.exist?(File.join(unpack_dir, php[:version])) }
    only_if { node['platform'] == 'ubuntu' && node['platform_version'] == '12.04' }
  end
end
