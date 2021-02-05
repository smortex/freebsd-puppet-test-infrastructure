# frozen_string_literal: true

require 'json'
require 'socket'

environmentpath = ARGV[0]
environment     = ARGV[1]

# Get the path to the Code Manager deployment info file.
r10k_deploy_file_path = File.join(environmentpath, environment, '.r10k-deploy.json')

# Get the first 8 characters of the commit ID out of the deployment file.
commit_id = JSON.parse(File.read(r10k_deploy_file_path))['signature'][0...7]

# Show the compiling master, environment name, and commit ID.
puts "#{environment}-#{commit_id}"
