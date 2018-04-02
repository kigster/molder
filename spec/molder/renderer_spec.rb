require 'spec_helper'

module Molder
  RSpec.describe Renderer do
    let(:file) { 'spec/fixtures/knife-ec2.yml' }
    subject(:config) { Configuration.load(file) }

    let(:template) { 'web-a' }
    let(:command) { :provision }
    let(:args) { config.commands[command].args }
    let(:params) { Template.normalize(config.templates[template]) }

    context 'test setup' do
      context 'args and params' do
        it 'should not be nil' do
          expect(args).to_not be_nil
          expect(params).to_not be_nil
          expect(params).to be_a_kind_of(Hash)
        end
      end
    end

    let(:renderer) { described_class.new(args) }

    context '#render' do
      context 'without environment provided' do
        it 'should raise LiquidTemplateError when environment is undefined' do
          expect { renderer.render(params) }.to raise_error(LiquidTemplateError)
        end
      end

      context 'with environment set' do
        before { params[:environment] = 'production' }

        let(:result) { renderer.render(params) }
        let(:expected) { 'echo knife ec2 server create -N web-a -I ami-f9u98f -Z us-east1-a -f c5.4xlarge --environment production --subnet subnet-ff09898 -g ssg-f8987987 -r role[base],role[web],role[zone-a] -S ubuntu_key -i ~/.ssh/ec2.pem --ssh-user ubuntu'}

        it 'should render the template' do
          expect(result).to eq expected
        end
      end
    end
  end
end
