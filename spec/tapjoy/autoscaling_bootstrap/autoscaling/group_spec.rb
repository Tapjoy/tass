require_relative '../../../spec_helper'

context Tapjoy::AutoscalingBootstrap::Autoscaling::Group do
  context 'autoscaling group with elb', :asg => 'new_with_elb' do
    describe '#new', :vcr do
      it 'initializes with elb', :asg => 'init_with_elb' do
        puts 'Initializing ASG w/ ELB...'
        Tapjoy::AutoscalingBootstrap.create_elb = true
        asg = Tapjoy::AutoscalingBootstrap::Autoscaling::Group.new
        expect(asg).to be_instance_of Tapjoy::AutoscalingBootstrap::Autoscaling::Group
        expect(asg.instance_variable_get(:@scaler_name)).to eql Tapjoy::AutoscalingBootstrap.scaler_name
        expect(asg.instance_variable_get(:@config_name)).to eql Tapjoy::AutoscalingBootstrap.config_name
        expect(asg.instance_variable_get(:@elb_name)).to eql Tapjoy::AutoscalingBootstrap.elb_name
        expect(asg.instance_variable_get(:@create_elb)).to eql true
      end
    end

    describe '#create', :vcr do
      it 'creates group with elb', :asg => 'create_with_elb' do
        puts 'Creating ASG with ELB...'
        Tapjoy::AutoscalingBootstrap.create_elb = true
        asg = Tapjoy::AutoscalingBootstrap::Autoscaling::Group.new
        groups = %w(asb-test qa tapbase)
        expect(asg).to be_instance_of Tapjoy::AutoscalingBootstrap::Autoscaling::Group

        expect{asg.create(config: new_config, aws_env: aws_env,
          user_data: user_data)}.to_not raise_error
      end
    end
  end

  context 'autoscaling group without elb', :asg => 'new_no_elb' do
    describe '#new', :vcr do
      it 'initializes without elb', :asg => 'init_no_elb' do
        puts 'Initializing ASG w/o ELB...'
        Tapjoy::AutoscalingBootstrap.create_elb = false
        asg = Tapjoy::AutoscalingBootstrap::Autoscaling::Group.new
        expect(asg).to be_instance_of Tapjoy::AutoscalingBootstrap::Autoscaling::Group
        expect(asg.instance_variable_get(:@scaler_name)).to eql Tapjoy::AutoscalingBootstrap.scaler_name
        expect(asg.instance_variable_get(:@config_name)).to eql Tapjoy::AutoscalingBootstrap.config_name
        expect(asg.instance_variable_get(:@elb_name)).to eql Tapjoy::AutoscalingBootstrap.elb_name
        expect(asg.instance_variable_get(:@create_elb)).to eql false
      end
    end

    describe '#create', :vcr do
      it 'creates group without elb', :asg => 'create_no_elb' do
        puts 'Initializing ASG w/o ELB...'
        Tapjoy::AutoscalingBootstrap.create_elb = false
        asg = Tapjoy::AutoscalingBootstrap::Autoscaling::Group.new
        expect(asg).to be_instance_of Tapjoy::AutoscalingBootstrap::Autoscaling::Group

        expect{asg.create(config: new_config, aws_env: aws_env,
          user_data: user_data)}.to_not raise_error
      end
    end
  end

  context 'dynamically scale auto scaling group', asg: 'dynamic_scale' do
    describe '#scale' do
      it 'scales cluster up' do
        asg = Tapjoy::AutoscalingBootstrap::Autoscaling::Group.new
        expect{asg.scale(new_config)}.to_not raise_error
      end
    end
  end

  context 'static auto scaling group', asg: 'static_scale' do
    describe '#scale' do
      it 'resizes cluster' do
        asg = Tapjoy::AutoscalingBootstrap::Autoscaling::Group.new
        expect{asg.scale(new_config)}.to_not raise_error
      end
    end
  end
end
