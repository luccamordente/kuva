require File.expand_path("../../lib/deploy/helpers",__FILE__)

set :application, 'guga'



bundle = "bundle"


begin

  puts ""

  print "Branch (master): "
  branch = STDIN.gets.strip
  branch = "master" if branch == ""

  print "Reload server? (true): "
  reload_server = eval STDIN.gets.strip
  reload_server = true if reload_server == nil

  print "Precompile assets? (true): "
  precompile_assets = eval STDIN.gets.strip
  precompile_assets = true if precompile_assets == nil

  puts "\n"
  puts "Branch            => #{branch}"
  puts "Reload server     => #{reload_server ? 'true' : 'false'}"
  puts "Precompile assets => #{precompile_assets ? 'true' : 'false'}"
  print "\nConfirma? [y/n] (y): "

end until (confirmation = STDIN.gets.match /^y?$/i)


def surun(command)
  password = fetch(:root_password, Capistrano::CLI.password_prompt("root password: "))
  run("su - lucca -c '#{command}'") do |channel, stream, output|
    channel.send_data("#{password}n") if output
  end
end

puts "\n\n"



set :scm, 'git'
set :scm_verbose, true
set :deploy_via, :remote_cache
set :restart_server_command, "/opt/nginx/sbin/nginx -s reload"
set :repository,  "ssh://lucca@201.17.161.70/home/lucca/apps/kuva"
set :branch, branch
set :user, "lucca"
set :use_sudo, false
set :password, "m0rd3nt3"
set :rvm_type, :system

role :app, "pcf"
role :web, "pcf"
role :db,  "pcf", :primary => true

set :deploy_to, "/home/lucca/www/kuva"


default_run_options[:pty] = true


after "deploy", "deploy:cleanup"
after "deploy:update_code", "deploy:copy_files"

# need to run after create_symlink, otherwise rake is not found oO
after "deploy:create_symlink", "deploy:bundle:install"
after "deploy:create_symlink", "deploy:assets:precompile" if precompile_assets

before "deploy:cleanup", "deploy:fix_permissions"
after "deploy:cleanup", "deploy:restart"


namespace :deploy do

  namespace :bundle do
    task :install do
      run "cd #{current_path} && bundle install --deployment --without test development"
    end
  end

  task :copy_files  do
    run "ln -nfs #{shared_path}/Gemfile.lock #{release_path}/Gemfile.lock"
    # run "cp #{shared_path}/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/assets #{release_path}/public/assets"
    run "ln -nfs #{shared_path}/bundle #{release_path}/vendor/bundle"
    # run "ln -nfs #{shared_path}/public/uploads #{release_path}/public/uploads"
  end

  task :fix_permissions do
    run "cd && if [ -f ./tmp ]; then #{sudo :as => 'lucca'} chmod -R 775 ./tmp; fi"
  end

  namespace :assets do
    task :precompile do
      run "cd #{release_path} && #{bundle} exec rake assets:precompile RAILS_GROUPS=assets RAILS_ENV=production"
    end
  end

  desc "Restart the web server"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt" if reload_server
  end

end
