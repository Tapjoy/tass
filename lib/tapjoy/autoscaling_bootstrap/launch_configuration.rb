module Tapjoy
  module AutoscalingBootstrap
    # This class is the central launching point for autoscaling group update
    class LaunchConfiguration
      # Initialize the class
      def initialize(new_config, aws_env, user_data)
        Tapjoy::AutoscalingBootstrap.scaler_name = "#{new_config[:name]}-group"
        Tapjoy::AutoscalingBootstrap.config_name = "#{new_config[:name]}-config"

        updated_config = current.to_hash.merge!(new_config)

        lc_name = "#{Tapjoy::AutoscalingBootstrap.config_name}_#{date_stamp}"
        update(config_name: lc_name, user_data: user_data,
          updated_config: updated_config, aws_env: aws_env)
      end

      def current
        begin
          current_config_name = Tapjoy::AutoscalingBootstrap::AWS::Autoscaling::Group.describe[:launch_configuration_name]
        rescue NoMethodError
          raise Tapjoy::AutoscalingBootstrap::Errors::InvalidAutoscalingGroup
        end
        puts "Current launch config is: #{current_config_name}\n\n"
        Tapjoy::AutoscalingBootstrap::AWS::Autoscaling::LaunchConfig.describe(current_config_name)
      end

      def update(config_name:, scaler_name: 'NaS', user_data: user_data,
        updated_config:, aws_env:)

        Tapjoy::AutoscalingBootstrap.config_name = config_name
        Tapjoy::AutoscalingBootstrap.scaler_name = scaler_name

        Tapjoy::AutoscalingBootstrap.config.create(updated_config, aws_env,
          user_data)
      end

      def date_stamp
        Time.now.strftime('%Y%m%d-%H%M%S')
      end
    end
  end
end
