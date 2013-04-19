require 'yaml'

module ContainerUtilities
  ENVVARS_FILE = File.dirname(__FILE__) + '/envvars'
  APP_ENVVARS_FILE = File.dirname(__FILE__) + '/envvars.d/appenv'

  module_function

  def template(infile, outfile, vars = ENV, to_s = :to_s)
    data = File.read(infile)
    data.gsub!(/\{(\w+)\}/) { vars[$1].send(to_s) }
    File.open(outfile, 'w') {|f| f.write(data) }
  end

  def load_envvars
    `. #{ENVVARS_FILE}; env`.split("\n").each do |line|
      key, value = *line.split('=', 2)
      ENV[key] = value if key && value
    end
    ENV
  end

  def application_config_file(base)
    File.join(base, '.ebextensions', 'config.yml')
  end

  def application_config(base)
    YAML.load_file application_config_file(base)
  rescue
    {}
  end

  def write_application_environment(base)
    config = application_config(base)
    if env = config['environment']
      File.open(APP_ENVVARS_FILE, 'w') do |file|
        env.each do |k, v|
          file.puts("export #{k}=#{v.to_s.inspect}")
        end
      end
    end
  end

  def execute_commands(event, stage, commands, app_path = ENV['EB_CONFIG_APP_ONDECK'])
    case commands
    when String
      return execute_command(event, stage, "__default__", commands, app_path)
    when Array
      commands = (1..commands.size).map {|c| '%02d_unnamed' % c }.zip(commands)
    when Hash
      commands = commands.sort_by {|k,v| k }
    else
      commands = []
    end

    if commands.empty?
      puts "No application scripts to execute in #{event}/#{stage}."
    else
      puts "Executing application scripts in #{event}/#{stage}..."
      commands.each do |file, command|
        return false unless execute_command(event, stage, file, command, app_path)
      end
    end

    true
  end

  def execute_command(event, stage, file, command, app_path = ENV['EB_CONFIG_APP_ONDECK'])
    sudo = false

    case command
    when String
      re = /\A(leader_only\s+)?sudo\s+/
      if command =~ re
        sudo = true
        command = command.gsub(re, '\1')
      end
    when Hash
      hash = command
      command = hash['command'].to_s
      sudo = hash['sudo']
      if hash['leader_only'] && ENV['EB_IS_COMMAND_LEADER'] != 'true'
        return true
      end
    else
      puts "Invalid apphook command (#{event}/#{stage}/#{file}): #{command.inspect}"
      return false
    end

    unless sudo
      command = "su -c '#{command.gsub("'", "'\\\\''")}' #{ENV['EB_CONFIG_APP_USER']}"
    end
    puts "apphook #{event}/#{stage}/#{file}: #{command}"
    output = `cd #{app_path} && #{command}`
    exit_code = $?.to_i
    success = exit_code == 0 ? "success" : "fail"
    puts "Done executing #{file} (#{success}) output:\n#{output}"

    exit_code == 0
  end

  def execute_app_hooks_path(path)
    load_envvars

    components = path.split('/')
    event = components[-3]
    stage = components.last[/app_(.+?)\.rb\Z/, 1]

    app_path = (event == 'appdeploy' && stage != 'post') ?
      ENV['EB_CONFIG_APP_ONDECK'] : ENV['EB_CONFIG_APP_CURRENT']
    config = application_config(app_path)

    commands = config.fetch('hooks', {}).fetch(event, {}).fetch(stage, nil)
    exit(1) if execute_commands(event, stage, commands, app_path) == false
  end
end
