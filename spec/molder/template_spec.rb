require 'spec_helper'

module Molder
  RSpec.describe Template do
    let(:config) { Configuration.new }
    let(:name) { 'boo' }
    let(:attrs) do
      Hashie::Mash.new(
        { image:    '12354',
          flavor:   'aaaa',
          run_list: {
            'role[base]' => nil,
            'role[web]'  => nil
          }
        }
      )
    end

    subject(:template) { described_class.new(config: config, name: name, command: 'provision', attributes: attrs, indexes: [1,2]) }

    its(:class) { should eq described_class }
    its(:attributes) { should include 'run_list' }
    context 'run_list' do
      subject { template.attributes['run_list'] }
      its(:class) { should be String }
      it { is_expected.to eq('role[base],role[web]')}
    end
  end
end
