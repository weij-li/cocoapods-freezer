require File.expand_path('../../spec_helper', __FILE__)

module Pod
  describe Command::Freeze do
    describe 'CLAide' do
      it 'registers it self' do
        Command.parse(%w{ freeze }).should.be.instance_of Command::Freezer
      end
    end
  end
end

