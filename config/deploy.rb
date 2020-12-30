# config valid for current version and patch releases of Capistrano
lock "~>3.14.1"

set :application,"sifa-chat"
set :repo_url,"git@github.com:sifaid/chatwoot.git"

set :rvm_ruby_version,  "2.7.2"
set :puma_threads,      [1, 16]
set :puma_workers,      1
set :linked_files,      %w{.env config/master.key config/database.yml}
set :linked_dirs,       %w{log tmp/cache tmp/sockets tmp/export tmp/pids public/assets public/uploads storage}
set :keep_releases,     1

SSHKit.config.command_map[:sidekiq] = "bundle exec sidekiq -C config/sidekiq.yml"
# set :bundle_path, nil
# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp
# before "deploy:assets:precompile", "deploy:yarn_install"
namespace :deploy do

  # desc "Restart application"
  # task :restart do
  #   on roles(:app), in: :sequence, wait: 5 do
  #     execute :touch, release_path.join("tmp/restart.txt")
  #   end
  # end

  after :publishing, :restart

  desc "Initial Deploy"
  task :initial do
    on roles(:app) do
      before "deploy:restart", "puma:start"
      invoke "deploy"
    end
  end

  desc "Start Puma Server"
  task :start_puma do
    on roles(:app), in: :sequence, wait: 1 do
      puts "======= release path is #{deploy_to} =========="
      puts "======= ruby version is #{fetch(:rvm_ruby_version)} =========="
      execute("cd #{deploy_to}/current/ && ~/.rvm/bin/rvm #{fetch(:rvm_ruby_version)} do bundle exec puma -C #{deploy_to}/shared/puma.rb --daemon")
    end
  end

  desc "Stop Puma Server"
  task :stop_puma do
    on roles(:app), in: :sequence, wait: 1 do
      puts "======= release path is #{deploy_to} =========="
      puts "======= ruby version is #{fetch(:rvm_ruby_version)} =========="
      execute("cd #{deploy_to}/current/ && ~/.rvm/bin/rvm #{fetch(:rvm_ruby_version)} do bundle exec pumactl -S #{deploy_to}/shared/tmp/pids/puma.state -F #{deploy_to}/shared/puma.rb stop")
    end
  end


end

namespace :rake do
  desc "Invoke rake task"
  task :invoke do
    run "cd #{deploy_to}/current"
    run "bundle exec rake #{ENV['task']} RAILS_ENV=#{rails_env}"
  end
end
# after :deploy, "puma:stop"
after :deploy, "deploy:start_puma"
# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, "/var/www/my_app_name"
# Rake::Task["deploy:assets:backup_manifest"].clear_actions
# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml"

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV["USER"]
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure
