module Tapjoy
  module AutoscalingBootstrap
    # This class configures autoscaling groups
    class ConfigureAutoscalers
      # required arguments first, then optional
      def initialize(misc_config:, aws_env:, user_data:, **unused_values)

        if misc_config[:create_as_group]
          sec_group_exists(aws_env[:security_groups]) unless misc_config[:vpc_subnets]
          if autoscaling_group_exists?
            update_autoscaling_group(misc_config, aws_env, user_data)
          else
            create_autoscaling_group(misc_config, aws_env, user_data)
          end
        else
          puts 'Skipping creating autoscale group and launch config'
          puts "\n"
        end
      end

      private

      # Check if ASG exists so we know whether to create or update
      def autoscaling_group_exists?
        Tapjoy::AutoscalingBootstrap::AWS::Autoscaling::Group.describe.nil? ? false : true
      end

      # Check if security group exists and create it if it does not
      def sec_group_exists(groups)
        groups.each do |group|
          begin
            puts "Verifying #{group} exists..."
            group = Tapjoy::AutoscalingBootstrap::AWS::EC2.describe_security_groups(group)
          rescue Aws::EC2::Errors::InvalidGroupNotFound => err
            STDERR.puts "Warning: #{err}"
            puts "Creating #{group} for #{Tapjoy::AutoscalingBootstrap.scaler_name}"
            Tapjoy::AutoscalingBootstrap::AWS::EC2.create_security_group(group)
          end
        end
      end

      # Create ASG logic
      def create_autoscaling_group(misc_config, aws_env, user_data)
        Tapjoy::AutoscalingBootstrap.group.create(config: misc_config,
        aws_env: aws_env, user_data: user_data)
      end

      def update_autoscaling_group(misc_config, aws_env, user_data)
        Tapjoy::AutoscalingBootstrap.group.update(
          config: misc_config,
          aws_env: aws_env,
          user_data: user_data
        )
      end
    end
  end
end
