require 'aruba_helper'

RSpec.describe 'command provision', :type => :aruba do
  let(:command) { 'exe/molder ' + args }
  let(:output) { last_command_started.stdout.chomp }
  let(:config_file) { "#{::Molder::PROJECT_ROOT}/spec/fixtures/knife-ec2.yml" }

  context 'help' do
    let(:args) { "provision web-a[1,2] -n -c #{config_file} -a environment=moo" }

    it 'should point to an existing config file' do
      expect(File.exist?(config_file)).to be(true)
    end

    it 'should generate a correct command' do
      expect(command).to eq("exe/molder provision web-a[1,2] -n -c #{config_file} -a environment=moo")
    end

    context 'running --dry-run' do
      before { run command }
      it 'should print two commands' do
        expect(output).to match(%r{echo knife ec2 server create -N web001-a -I ami-f9u98f -Z us-east1-a -f c5\.4xlarge --environment moo --subnet subnet-ff09898 -g ssg-f8987987 -r role\[base\],role\[web\],role\[zone\-a\] -S ubuntu_key -i ~/\.ssh/ec2\.pem --ssh-user ubuntu})
        expect(output).to match(%r(echo knife ec2 server create -N web002-a -I ami-f9u98f -Z us-east1-a -f c5\.4xlarge --environment moo --subnet subnet-ff09898 -g ssg-f8987987 -r role\[base\],role\[web\],role\[zone\-a\] -S ubuntu_key -i ~/\.ssh/ec2\.pem --ssh-user ubuntu))
        expect(output).to match(%r{Dry-run})
      end
    end
  end

  context 'multiple --attrs' do
    let(:args) { "provision web-a[1,2] -n -c #{config_file} -a environment=moo -a flavor=very-big" }
    before { run command }
    it 'should print two commands' do
      expect(output).to match(%r{echo knife ec2 server create -N web001-a -I ami-f9u98f -Z us-east1-a -f very-big --environment moo --subnet subnet-ff09898 -g ssg-f8987987 -r role\[base\],role\[web\],role\[zone\-a\] -S ubuntu_key -i ~/\.ssh/ec2\.pem --ssh-user ubuntu})
      expect(output).to match(%r(echo knife ec2 server create -N web002-a -I ami-f9u98f -Z us-east1-a -f very-big --environment moo --subnet subnet-ff09898 -g ssg-f8987987 -r role\[base\],role\[web\],role\[zone\-a\] -S ubuntu_key -i ~/\.ssh/ec2\.pem --ssh-user ubuntu))
      expect(output).to match(%r{Dry-run})
    end
  end
end
