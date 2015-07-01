module Tapjoy
  module AutoscalingBootstrap
    module Autoscaling
      # Code specific to Launch Configs
      class Config

        # Create launch configuration
        def create(config, aws_env, user_data)

          if exists
            delete
          else
            puts "Launch config #{Tapjoy::AutoscalingBootstrap.config_name} does not exist, continuing..."
          end

          puts "Creating launch config: #{Tapjoy::AutoscalingBootstrap.config_name}"
          begin
            Tapjoy::AutoscalingBootstrap::Base.new.sec_group_exists(
              aws_env[:security_groups])
            Tapjoy::AutoscalingBootstrap::AWS::Autoscaling::LaunchConfig.create(
              **config, **aws_env, user_data: user_data)
          rescue Aws::AutoScaling::Errors::ValidationError => err
            STDERR.puts "Cannot create launch configuration: #{err}"
          end
        end

        # Check if launch configuration exists
        def exists
          !Tapjoy::AutoscalingBootstrap::AWS::Autoscaling::LaunchConfig.describe(
            Tapjoy::AutoscalingBootstrap.config_name).nil?
        end

        def delete
          puts "Deleting launch config #{Tapjoy::AutoscalingBootstrap.config_name}"
          Tapjoy::AutoscalingBootstrap::AWS::Autoscaling::LaunchConfig.delete
        end
      end
    end
  end
end
