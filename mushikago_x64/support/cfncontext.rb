#!/usr/bin/env ruby

require 'rubygems'
require 'json'
require File.dirname(__FILE__) + '/util'

ContainerUtilities.load_envvars
puts JSON.dump({
  'env' => ENV.to_hash,
  'cwd' => ENV['EB_CONFIG_APP_ONDECK']
})
