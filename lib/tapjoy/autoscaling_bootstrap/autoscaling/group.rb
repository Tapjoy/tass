module Tapjoy
  module AutoscalingBootstrap
    module Autoscaling
      # Class for Autoscaling groups
      class Group

        # Initialize the class
        def initialize
          @scaler_name = Tapjoy::AutoscalingBootstrap.scaler_name
          @config_name = Tapjoy::AutoscalingBootstrap.config_name
          @elb_name    = Tapjoy::AutoscalingBootstrap.elb_name
          @create_elb  = Tapjoy::AutoscalingBootstrap.create_elb
        end

        # Create autoscaling group
        def create(config:, aws_env:, user_data:)
          if exists
            begin
              zero_autoscale_group
            rescue Aws::AutoScaling::Errors::ValidationError => err
              abort("Cannot remove existing AS group #{@scaler_name}. Error: #{err}")
            end
          else
            "Scaling group #{@scaler_name} does not exist, continuing..."
          end

          Tapjoy::AutoscalingBootstrap.config.create(config, aws_env,
            user_data)

          puts "Creating scaling group: #{@scaler_name}"
          Tapjoy::AutoscalingBootstrap::AWS::Autoscaling::Group.create(**config)
        end

        # Check if autoscale group exists
        def exists
          !Tapjoy::AutoscalingBootstrap::AWS::Autoscaling::Group.describe.nil?
        end

        # Encode user data into required base64 form
        def encode_user_data(user_data)
          Base64.encode64("#{user_data}")
        end

        # Create tags array to pass to autoscaling group
        def generate_tags(tags)
          tag_array = Array.new
          return [] if tags.nil? || tags.empty?
          tags.each do |t|
            return [] if t.nil?
            t.each_pair do |key, value|
              tag_array << {
                resource_id: @scaler_name,
                resource_type: 'auto-scaling-group',
                key: key.to_s,
                value: value,
                propagate_at_launch: true,
              }
            end
          end
          tag_array
        end

        # Scale auto scaling groups
        def scale(config)
          if config[:scaling_type].eql?('dynamic')
            Tapjoy::AutoscalingBootstrap::AWS::Autoscaling::Group.resize(
              **config[:instance_counts])
          elsif config[:scaling_type].eql?('static')
            scale_static(config)
          else
            abort('Unknown scaling type')
          end
        end

        private

        # Logic for scaling static clusters
        def scale_static(config)
          current_count = Tapjoy::AutoscalingBootstrap::EC2.count_static_instances(config)
          count_delta = config[:instance_counts][:desired] - current_count
          if count_delta < 0
            count_delta = count_delta.abs
            puts "Scaling #{count_delta} instances down"
            abort('Instances to terminate must be specified') unless config.key?(:instance_ids)
            unless config[:instance_ids].length.eql?(count_delta)
              fail Tapjoy::AutoscalingBootstrap::Errors::IncorrectNumberIds
            end
            disable_termination_protection(config[:instance_ids])
            Tapjoy::AutoscalingBootstrap::AWS::EC2.terminate_instances(config[:instance_ids])
          elsif count_delta > 0
            puts 'Scaling up...'
            puts count_delta
            Tapjoy::AutoscalingBootstrap::AWS::Autoscaling::Group.resize(
              min: 0, max: count_delta, desired: count_delta)
            wait_for_asg_to_populate(config[:instance_counts][:desired], config)
            enable_termination_protection
            Tapjoy::AutoscalingBootstrap::AWS::Autoscaling::Group.detach
          else
            puts 'No action needed'
          end
        end

        # Helper method to disable termination protection
        def disable_termination_protection(instance_ids)
          instance_ids.each do |instance|
            Tapjoy::AutoscalingBootstrap::EC2.disable_termination_protection(instance)
          end
        end
        # Helper method to enable termination protection
        def enable_termination_protection
          asg = Tapjoy::AutoscalingBootstrap::AWS::Autoscaling::Group.describe
          asg.instances.map(&:instance_id).each do |instance|
            Tapjoy::AutoscalingBootstrap::EC2.enable_termination_protection(instance)
          end
        end

        # Clear out existing autoscaling group
        def zero_autoscale_group
          Tapjoy::AutoscalingBootstrap::AWS::Autoscaling::Group.resize

          wait_for_asg_to_quiet

          Tapjoy::AutoscalingBootstrap::AWS::Autoscaling::Group.delete

          wait_for_asg_to_delete

          abort("#{@scaler_name} still exists") if exists
        end

        # Create termination notification for Chef
        def create_termination_notification(misc_config)
          puts 'Create termination notification'
          begin
            Tapjoy::AutoscalingBootstrap::AWS::Autoscaling.put_notification_configuration(
              **misc_config)
          rescue Aws::AutoScaling::Errors::ValidationError => err
            STDERR.puts "Cannot create notification: #{err}"
          end
        end

        # Wait for ASG activities to settle before proceeding
        def wait_for_asg_to_quiet
          5.times do |tries|
            puts "Waiting for scaling activities to settle (#{tries + 1} of 5)..."
            as_group_size=Tapjoy::AutoscalingBootstrap::AWS::Autoscaling::Group.describe[:instances].length

            break if as_group_size.eql?(0)

            Tapjoy::AutoscalingBootstrap::Base.new.aws_wait(tries)
          end
        end

        # Wait for ASG to be deleted
        def wait_for_asg_to_delete
          5.times do |tries|
            puts "Waiting for auto scaling group to remove itself (#{tries + 1} of 5)..."
            break unless exists
            Tapjoy::AutoscalingBootstrap::Base.new.aws_wait(tries)
          end
        end

        # Wait for ASG to populate
        def wait_for_asg_to_populate(desired, config)
          current_count = Tapjoy::AutoscalingBootstrap::EC2.count_static_instances(config)
          tries = 0
          until current_count.eql?(desired) do
            tries += 1
            Tapjoy::AutoscalingBootstrap::Base.new.aws_wait(tries)
            current_count = Tapjoy::AutoscalingBootstrap::EC2.count_static_instances(config)
          end
        end
      end
    end
  end
end
