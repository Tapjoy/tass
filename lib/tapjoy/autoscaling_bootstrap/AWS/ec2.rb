module Tapjoy
  module AutoscalingBootstrap
    module AWS
      # This class contains AWS methods for EC2
      module EC2
        class << self
          def client
            @client ||= Aws::EC2::Client.new
          end

          def describe_security_groups(group)
            self.client.describe_security_groups(group_names: [group])
          end

          def create_security_group(group)
            self.client.create_security_group(group_name: group,
              description: "Security group for #{Tapjoy::AutoscalingBootstrap.scaler_name}")
          end

          def describe_instances_by_tag(config)
            self.client.describe_instances(filters: [
              {name: 'tag:Name', values: [config[:name]]},
              {name: 'instance-state-name', values: %w(running)}
              ])
          end

          def toggle_termination_protection(instance_id, state)
            client.modify_instance_attribute(
              instance_id: instance_id,
              attribute: 'disableApiTermination',
              value: state)
          end

          def terminate_instances(instance_ids)
            client.terminate_instances(instance_ids: instance_ids)
          end

          def request_spot_fleet(spot_price:, target_capacity:,
            iam_fleet_role:, excess_capacity_termination_policy:,
            allocation_strategy:, userdata_dir:, **config)
            config[:launch_specifications].each do |spec|
              # Make a fresh copy of the passed config
              # so we can set the recipes and tags to be used in the user_data
              user_data_config = {}
              user_data_config.merge!(config)
              set_recipes_and_tags(user_data_config, spec)
              user_data = Tapjoy::AutoscalingBootstrap::Base.new.generate_user_data(
                userdata_dir, spec[:bootstrap_script], user_data_config)
              spec[:user_data] = Base64.encode64("#{user_data}")
              # Remove the bootstrap related config from the launch specification
              # or the EC2 Spot Fleet call will fail
              spec.delete(:bootstrap_script)
              spec.delete(:recipes)
              spec.delete(:tags)
            end

            client.request_spot_fleet(
              spot_fleet_request_config: { # required
                spot_price: spot_price, # required
                target_capacity: target_capacity, # required
                iam_fleet_role: iam_fleet_role, # required
                launch_specifications: config[:launch_specifications],
                excess_capacity_termination_policy: excess_capacity_termination_policy,
                allocation_strategy: allocation_strategy
              })
          end

          def set_recipes_and_tags(user_data_config, launch_spec_config)
            # Look for specified recipes and tags in the spot fleet launch specification
            # and set the appropriate values
            keys = [:recipes, :tags]
            keys.each do |key|
              if launch_spec_config[key]
                user_data_config[key] = launch_spec_config[key]
              else
                msg = "No #{key.to_s} have been specified for the " +
                  "#{launch_spec_config[:instance_type]} launch specification"
                abort(msg)
              end
            end
          end

        end
      end
    end
  end
end
