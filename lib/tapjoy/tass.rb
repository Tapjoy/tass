require_relative 'tass/aws'
require_relative 'tass/aws/cloudwatch'
module Tapjoy
  # module to hold new-style tass code
  module TASS
    class << self
      def plan
        outfile = File.join(Tapjoy::AutoscalingBootstrap.terraform_path, 'plan')
        has_plan = system("terraform plan -out=#{outfile} #{Tapjoy::AutoscalingBootstrap.terraform_path}", out: File::NULL)
        if has_plan
          puts `terraform show #{outfile}`
        else
          abort("Failed to write plan to #{outfile}")
        end

        abort('Exiting...') unless agree('Is this information correct? [y/n]')
      end

      def apply
        statefile = File.join(Tapjoy::AutoscalingBootstrap.terraform_path, 'terraform.state')
        planfile = File.join(Tapjoy::AutoscalingBootstrap.terraform_path, 'plan')
        begin
          puts `terraform apply -state=#{statefile} #{Tapjoy::AutoscalingBootstrap.terraform_path}`
        rescue
          abort("Failed to apply #{planfile} to #{statefile}")
        end
      end
    end
  end
end
