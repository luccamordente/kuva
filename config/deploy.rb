# require File.expand_path("../../lib/deploy/helpers",__FILE__)

set :application, 'guga'




def surun(command)
  password = fetch(:root_password, Capistrano::CLI.password_prompt("root password: "))
  run("su - lucca -c '#{command}'") do |channel, stream, output|
    channel.send_data("#{password}n") if output
  end
end

def create_unless_exist type, path
  case type.to_s
    when 'f'
      run "if [ ! -f  #{path} ]; then touch #{path}; fi"
    when 'd'
      run "if [ ! -d  #{path} ]; then mkdir -p #{path}; fi"
  end
end






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
  puts "Reload server     => #{reload_server     ? 'true' : 'false'}"
  puts "Precompile assets => #{precompile_assets ? 'true' : 'false'}"
  print "\nConfirma? [y/n] (y): "

end until (confirmation = STDIN.gets.match /^y?$/i)



puts "\n\n"



set :scm, 'git'
set :scm_verbose, true
# set :deploy_via, :remote_cache
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


after "deploy"            , "deploy:cleanup"

before "deploy:create_symlink", "deploy:copy_files"
before "deploy:create_symlink", "deploy:bundle:install"
before "deploy:create_symlink", "deploy:assets:precompile" if precompile_assets

before "deploy:cleanup", "deploy:fix_permissions"
after "deploy:cleanup", "deploy:restart"




namespace :deploy do

  namespace :bundle do
    task :install do
      run "cd #{release_path} && bundle install --deployment --without test development"
    end
  end

  task :copy_files  do
    # create_unless_exist :f, "#{shared_path}/Gemfile.lock"
    # run "ln -nfs #{shared_path}/Gemfile.lock #{release_path}/Gemfile.lock"

    create_unless_exist :f, "#{shared_path}/mongoid.yml"
    run "cp #{shared_path}/mongoid.yml #{release_path}/config/mongoid.yml"

    create_unless_exist :d, "#{shared_path}/assets"
    run "ln -nfs #{shared_path}/assets #{release_path}/public/assets"

    create_unless_exist :d, "#{shared_path}/bundle"
    run "ln -nfs #{shared_path}/bundle #{release_path}/vendor/bundle"

    # create_unless_exist :d, "#{shared_path}/uploads"
    # run "ln -nfs #{shared_path}/uploads #{release_path}/public/uploads"
  end

  task :fix_permissions do
    run "cd && if [ -f ./tmp ]; then #{sudo :as => 'lucca'} chmod -R 775 ./tmp; fi"
  end

  namespace :assets do
    task :precompile do
      run "cd #{release_path} && bundle exec rake assets:precompile RAILS_GROUPS=assets RAILS_ENV=production"
    end
  end

  desc "Restart the web server"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"  if reload_server
    run "curl http://127.0.0.1:9999 > /dev/null" if reload_server
  end

end
