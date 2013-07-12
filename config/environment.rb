# Load the rails application
require File.expand_path('../application', __FILE__)

require 'tibbr-api'

APP_CONFIG = YAML.load_file(File.join(Rails.root, "config", "app_config.yml"))

# Initialize the rails application
TibbrRetailsApp::Application.initialize!
