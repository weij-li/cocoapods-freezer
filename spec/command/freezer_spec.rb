require File.expand_path('../../spec_helper', __FILE__)

module Pod
  describe Command::Freezer do
    describe 'CLAide' do
      it 'registers it self' do
        Command.parse(%w{ freezer }).should.be.instance_of Command::Freezer
      end
    end
  end
end

