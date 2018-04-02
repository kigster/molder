require 'spec_helper'

module Molder
  RSpec.describe Configuration do
    let(:file) { 'spec/fixtures/knife-ec2.yml' }
    subject(:config) { described_class.load(file) }

    its(:class) { should eq described_class }
    its(:global) { should include 'organization' }

    context 'default_config' do
      subject { described_class.default }
      its(:templates) { should include 'web-a' }
      its(:commands) { should include 'provision' }
    end


  end
end
