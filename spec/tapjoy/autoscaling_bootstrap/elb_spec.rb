require 'spec_helper'

describe Tapjoy::AutoscalingBootstrap::ELB, :vcr do
  describe '#new' do
    let(:config) { new_config.merge({
      elb_health_target: 'http:80/healthz',
      elb_protocol:      'http',
      instance_port: 80,
      elb_port: 80,
    })}
    it 'name too long', :elb => 'name_error' do
      Tapjoy::AutoscalingBootstrap.elb_name = 'This name is far too long for an elastic load balancer'
      expect{Tapjoy::AutoscalingBootstrap::ELB.new.create(config,
        aws_env)}.to raise_error {Tapjoy::AutoscalingBootstrap::Errors::ELB::NameTooLong}
    end
  end

  context 'creates an elb', :elb => 'create' do
    describe '#create' do
      let(:config) { new_config.merge({
        elb_health_target: 'http:80/healthz',
        elb_protocol:      'http',
        instance_port: 80,
        elb_port: 80,
        elb_name: 'test-elb'
      })}

      # let(:elb_name) {'test-elb'}

      it 'has valid params' do
        puts 'Creating ELB...'
        expect{Tapjoy::AutoscalingBootstrap::ELB.new.create(config,
          aws_env)}.to_not raise_error
      end
    end

    describe '#health_check' do
      let(:config) { new_config.merge({
        elb_health_target: 'http:80/healthz',
        elb_protocol:      'http',
        instance_port: 80,
        elb_port: 80,
        elb_health_interval: 15,
        elb_health_timeout: 5,
        elb_unhealthy_threshold: 2,
        elb_healthy_threshold: 2
      })}
      it 'has valid params' do
        puts 'Configuring health check...'

        elb = Tapjoy::AutoscalingBootstrap::ELB.new
        expect(elb).to be_instance_of Tapjoy::AutoscalingBootstrap::ELB
        expect{elb.health_check(config)}.to_not raise_error
      end
    end

    after :all do
      puts 'Cleaning up...'
      elb = Tapjoy::AutoscalingBootstrap::ELB.new
      elb.delete if elb.exists
    end
  end
end
