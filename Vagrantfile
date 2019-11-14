require 'yaml'
require 'fileutils'

domains = {
  frontend: 'erec.test',
  backend:  'erec-backend.test',
  phpmyadmin: 'phpMyAdmin'
}

config = {
  local: 'config/vagrant-local.yml',
  example: 'config/vagrant-local.example.yml'
}

# copy config from example if local config not exists
FileUtils.cp config[:example], config[:local] unless File.exist?(config[:local])
# read config
options = YAML.load_file config[:local]

# check github token
if options['github_token'].nil? || options['github_token'].to_s.length != 40
  puts "You must place REAL GitHub token into configuration:\n/yii2-app-advanced/vagrant/config/vagrant-local.yml"
  exit
end

# vagrant configurate
Vagrant.configure(2) do |config|
  # select the box
  config.vm.box = 'ubuntu/bionic64'

  # should we ask about box updates?
  config.vm.box_check_update = options['box_check_update']

  config.vm.provider 'virtualbox' do |vb|
    # machine cpus count
    vb.cpus = options['cpus']
    # machine memory size
    vb.memory = options['memory']
    # machine name (for VirtualBox UI)
    vb.name = options['machine_name']
  end

  # machine name (for vagrant console)
  config.vm.define options['machine_name']

  # machine name (for guest machine console)
  config.vm.hostname = options['machine_name']

  # network settings
  config.vm.network 'private_network', ip: options['ip']

  # sync: folder 'erec-yii2' (host machine) -> folder '/var/www/html' (guest machine)
  # put your own path where you see ./
  config.vm.synced_folder options['path_to_erec'], '/var/www/html/erec', owner: 'vagrant', group: 'vagrant'

  # sync: folder 'cps-yii2' (host machine) -> folder '/var/www/html' ( guest machine)
  # put your own path in vagrant-local.yml
  # config.vm.synced_folder options['path_to_cps'], '/var/www/html/cps', owner: 'vagrant', group: 'vagrant'

  # disable folder '/vagrant' (guest machine)
  config.vm.synced_folder '.', '/vagrant', disabled: true

  # hosts settings (host machine)
  config.vm.provision :hostmanager
  config.hostmanager.enabled            = true
  config.hostmanager.manage_host        = true
  config.hostmanager.ignore_private_ip  = false
  config.hostmanager.include_offline    = true
  config.hostmanager.aliases            = domains.values

  # provisioners
  config.vm.provision 'shell', path: 'provision/once-as-root.sh', args: [options['timezone']]
  config.vm.provision 'shell', path: 'provision/once-as-vagrant.sh', args: [options['github_token']], privileged: false
  config.vm.provision 'shell', path: 'provision/always-as-root.sh', run: 'always'

  # post-install message (vagrant console)
  config.vm.post_up_message = "Erec frontend URL: http://#{domains[:frontend]}\nBackend URL: http://#{domains[:backend]}"
end
