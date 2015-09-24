module Tapjoy
  module AutoscalingBootstrap
    # This class handles the comparison of local configs against upstream
    class Audit
      def initialize(config)
        local_config = Hash(**clean_local_hash(config))

        remote_launch_config = Tapjoy::AutoscalingBootstrap::AWS::Autoscaling::LaunchConfig.describe(Tapjoy::AutoscalingBootstrap.config_name).to_h
        remote_group_config = Tapjoy::AutoscalingBootstrap::AWS::Autoscaling::Group.describe.to_h
        # Combine launch config and group config into a single hash
        remote_config = remote_launch_config.merge!(remote_group_config)
        clean_remote_hash(remote_config)
        puts "\n\n\n"
        HashDiff.diff(local_config, remote_config).each do |op, key, value|
          puts "%s %s %-60s" % [op, key, value]
        end
      end

      private
      # fix key names to match AWS standards
      def clean_local_hash(config)
        config[:key_name] = config.delete :keypair
        config[:launch_configuration_name] = Tapjoy::AutoscalingBootstrap.config_name
        keys = %w(bootstrap_script chef_server_url clobber clobber_elb
          create_as_group)
        delete_keys(config, keys)

        config
      end

      # Remove keys that the local config does not support
      def clean_remote_hash(config)
        keys = %w(kernel_id instances desired_capacity min_size max_size
          ramdisk_id)
        delete_keys(config, keys)
        config[:tags].each do |tag|
          delete_keys(tag, %w(resource_id))
          tag[tag[:key].to_sym] = tag.delete :value
          delete_keys(tag, %w(resource_type propagate_at_launch key))
        end
      end

      # Helper method to delete keys
      def delete_keys(config, keys)
        keys.each {|key| config.delete key.to_sym}
      end
    end
  end
end
