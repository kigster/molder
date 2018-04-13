require 'aruba_helper'

RSpec.describe 'command help', :type => :aruba do
  let(:command) { "molder #{args}" }
  let(:output) { last_command_started.stdout.chomp }

  before { run_simple command }

  context 'help' do
    let(:args) { '-h' }
    it 'should print help' do
      expect(output).to match(/DESCRIPTION/)
    end
  end

end
