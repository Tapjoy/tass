require 'awrence'

module Tapjoy
  module AutoscalingBootstrap
    # This module formats configuration data for use with cloudformation requests
    module Cloudformation
      class << self
        # Prep the options for inclusion in a cloudformation request
        def prepare_options_hash(config)
          puts "Preparing options for cloudwatch request"

          # Initialize a cloudwatch hash so we can create a template body for the cf request
          cf_hash = {
            # TODO: turn AWS template version into cli param with sensible default
            "AWSTemplateFormatVersion" => "2010-09-09",
            "Resources" => {}
          }

          # Now process the recognized resources so we can format them properly
          config[:stack].keys.each do |key|
            case key
            when :spot_fleet
              cf_hash["Resources"][config[:stack][key][:name]] = self.process_spot_fleet_config(config)
              # TODO: Implement other resource types (asg, launch config, etc.)
            else
              puts "Unrecognized resource #{key} specified in stack. Skipping #{key}."
            end
          end

          request_params = {
            #TODO: add other required params for request
            :template_body => cf_hash.to_json
          }
        end

        def process_spot_fleet_config(config)
          # Take the spot fleet config data and format it into a usuable item in the Resources hash
          spot_fleet_hash = {
            "Type" => "AWS::EC2::SpotFleet",
            "Properties" => {  "SpotFleetRequestConfigData" => ""}
          }

          # To keep the yaml config size manageable we parse out the specified bootstrap script
          # into an array here and apply it to each launch config
          filename = config[:filename]
          facet_file    = filename
          userdata_dir  = "#{File.expand_path('../../..', facet_file)}/userdata"
          # CamelCase the spot fleet hash keys so they'll be recognized by AWS. Thank you awrence
          spot_fleet_config = config[:stack][:spot_fleet][:config_data].to_camel_keys
          # Use the newlines to split the config into an array, then add the newline characters back
          # so we can reconstitute the bootstrap properly later
          boostrap_script_array = Tapjoy::AutoscalingBootstrap::Base.new.generate_user_data(userdata_dir,
            config[:stack][:spot_fleet][:bootstrap_script], config).split("\n").map{|line| line << "\n"}
          # Add the bootstrap as all of the launch config's UserData setting.
          # Fn calls are interpreted by cloudformation/spotfleet as a way to reconstitute the script
          spot_fleet_config[:LaunchSpecifications].each{|ls| ls["UserData"] = {"Fn::Base64" => {"Fn::Join" => ["", boostrap_script_array]}}}
          spot_fleet_config
        end

      end
    end
  end
end
