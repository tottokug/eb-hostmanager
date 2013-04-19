require File.dirname(__FILE__) + '/spawn_manager_orig'

module PhusionPassenger
  class SpawnManager
    def spawn_application_with_env(options)
      require '/opt/elasticbeanstalk/support/util'
      ContainerUtilities.load_envvars

      # Set Rack environment based on ENV
      %w(RACK_ENV RAILS_ENV).each do |env|
        next if ENV[env].nil? || ENV[env].strip.empty?
        options['environment'] = ENV['RACK_ENV']
        break
      end

      spawn_application_without_env(options)
    end

    alias spawn_application_without_env spawn_application
    alias spawn_application spawn_application_with_env
  end
end
