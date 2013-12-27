require File.expand_path('../../spec_helper',__FILE__)

on_cruby do
  describe Handle::Command::Persistence do
    let(:fake_handle) { 'FAKE.PREFIX/FAKE.HANDLE' }
    let(:connection)  { double(Handle::Command::Connection) }
    let(:record) {
      record = Handle::Record.new
      record.add(:URL, 'http://www.example.edu/fake-handle').index = 2
      record.add(:Email, 'handle@example.edu').index = 6
      record << Handle::Field::HSAdmin.new('0.NA/FAKE.ADMIN')
      record.connection = connection
      record
    }
    subject { record }

    it "#reload" do
      current = subject.to_s
      subject.handle = fake_handle
      connection.should_receive(:resolve_handle).with(fake_handle) { Handle::Record.from_data(subject.to_s) }
      subject.reload
      expect(subject.to_s).to eq(current)
    end

    it "#destroy" do
      subject.handle = fake_handle
      connection.should_receive(:delete_handle).with(fake_handle)
      subject.destroy
    end

    describe "#save" do
      it "nil handle, no param" do
        expect { subject.save }.to raise_error(Handle::HandleError)
      end

      it "nil handle, param" do
        connection.should_receive(:create_handle).with(fake_handle, subject) { true }
        expect(subject.save(fake_handle)).to be_true
      end

      it "existing handle, no existing record" do
        subject.handle = fake_handle
        current = subject.to_s
        connection.should_receive(:resolve_handle).with(fake_handle) { raise Handle::NotFound.new('Handle not found') }
        connection.should_receive(:create_handle) { |handle, record| expect(record).to eq(subject) }
        subject.save
      end

      it "change existing record" do
        subject.handle = fake_handle
        current = subject.to_s
        connection.should_receive(:resolve_handle).with(fake_handle) { Handle::Record.from_data(current) }
        subject.delete(subject.find_by_index(6))
        subject.add(:URN, 'info:example:fake-handle')
        connection.should_receive(:delete_handle_values) { |handle, record| expect(record.length).to eq(1) }
        connection.should_receive(:add_handle_values)    { |handle, record| expect(record.length).to eq(1) }
        connection.should_receive(:update_handle_values) { |handle, record| expect(record.length).to eq(2) }
        subject.save
      end
    end

  end
end
