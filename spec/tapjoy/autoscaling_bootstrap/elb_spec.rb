require 'spec_helper'

describe Tapjoy::AutoscalingBootstrap::ELB, :vcr do
  describe '#new' do
    it 'name too long', :elb => 'name_error' do
      Tapjoy::AutoscalingBootstrap.elb_name = 'This name is far too long for an elastic load balancer'
      expect{
        Tapjoy::AutoscalingBootstrap::ELB.new(
          @elb_hash, @clobber_elb, @zones, @security_groups
        )
      }.to raise_error {Tapjoy::AutoscalingBootstrap::Errors::ELB::NameTooLong}
    end
  end

  context 'creates an elb', :elb => 'create' do
    before(:all) do
      Tapjoy::AutoscalingBootstrap.elb_name = @elb_name
      @elb = Tapjoy::AutoscalingBootstrap::ELB.new(
        @elb_hash, @clobber_elb, @zones, @security_groups)
    end

    describe '#create' do
      it 'has valid params' do
        puts 'Creating ELB...'
        expect{@elb.create(
          @elb_hash[Tapjoy::AutoscalingBootstrap.elb_name])}.to_not raise_error
      end
    end

    describe '#health_check' do
      it 'has valid params' do
        puts 'Configuring health check...'
        expect(@elb).to be_instance_of Tapjoy::AutoscalingBootstrap::ELB
        expect{@elb.health_check(
          @elb_hash[Tapjoy::AutoscalingBootstrap.elb_name])}.to_not raise_error
      end
    end

    after(:all) do
      puts 'Cleaning up...'
      @elb.delete if @elb.exists
    end
  end
end
