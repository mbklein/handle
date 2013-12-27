require File.expand_path('../../spec_helper',__FILE__)

on_jruby do
  describe Handle::Java::Connection do
    describe "#initialize" do
      it "file-based private key" do
        File.should_receive(:exists?).with('privkey') { true }
        File.should_receive(:read).with('privkey') { 'privkey_content' }
        Handle::Java::Native::HSAdapterFactory.should_receive(:new_instance) do |handle, index, key, secret|
          expect(handle).to eq('0.NA/FAKE.ADMIN')
          expect(index).to eq(300)
          expect(secret.collect(&:chr).join).to eq('keypass')
          expect(key.collect(&:chr).join).to eq('privkey_content')
        end
        Handle::Java::Connection.new('0.NA/FAKE.ADMIN', 300, 'privkey', 'keypass')
      end

      it "literal private key" do
        File.should_receive(:exists?).with('privkey') { false }
        File.should_not_receive(:read)
        Handle::Java::Native::HSAdapterFactory.should_receive(:new_instance) do |handle, index, key, secret|
          expect(handle).to eq('0.NA/FAKE.ADMIN')
          expect(index).to eq(300)
          expect(secret.collect(&:chr).join).to eq('keypass')
          expect(key.collect(&:chr).join).to eq('privkey')
        end
        Handle::Java::Connection.new('0.NA/FAKE.ADMIN', 300, 'privkey', 'keypass')
      end

      it "shared secret" do
        File.should_not_receive(:exists?)
        File.should_not_receive(:read)
        Handle::Java::Native::HSAdapterFactory.should_receive(:new_instance) do |handle, index, key|
          expect(handle).to eq('0.NA/FAKE.ADMIN')
          expect(index).to eq(301)
          expect(key.collect(&:chr).join).to eq('seckey')
        end
        Handle::Java::Connection.new('0.NA/FAKE.ADMIN', 301, 'seckey')
      end
    end

    describe "handle manipulation" do
      let(:fake_handle) { 'FAKE.PREFIX/FAKE.HANDLE' }
      let(:new_handle)  { 'FAKE.PREFIX/NEW.HANDLE'  }
      let(:bad_handle)  { 'FAKE.PREFIX/NEW.HANDLE'  }

      let(:record) {
        record = Handle::Record.new
        record.add(:URL, 'http://www.example.edu/fake-handle').index = 2
        record.add(:Email, 'handle@example.edu').index = 6
        record << Handle::Field::HSAdmin.new('0.NA/FAKE.ADMIN')
        record
      }
      let(:server) { double(Handle::Java::Native::HSAdapter) }
      subject { Handle::Java::Connection.new('0.NA/FAKE.ADMIN', 300, 'privkey', 'keypass') }

      before(:each) do
        Handle::Java::Native::HSAdapterFactory.stub(:new_instance) { server }
        Handle::Java::Native::HSAdapterFactory.stub(:newInstance)  { server }
      end

      it "#native" do
        expect(subject.native).to eq(server)
      end

      it "#use_udp" do
        server.should_receive(:setUseUDP).with(false)
        subject.use_udp = false
      end

      it "#resolve_handle" do
        server.should_receive(:resolveHandle).with(fake_handle, anything(), anything(), anything()) { record.to_s }
        expect(subject.resolve_handle(fake_handle)).to eq(record)
      end

      it "#resolve_handle (not found)" do
        server.should_receive(:resolveHandle).with(bad_handle, anything(), anything(), anything())  { raise Handle::Java::Native::HandleException.new(9, "Handle not found") }
        expect { subject.resolve_handle(bad_handle) }.to raise_error(Handle::NotFound)
      end

      it "#resolve_handle (other error)" do
        server.should_receive(:resolveHandle).with(bad_handle, anything(), anything(), anything())  { raise Handle::Java::Native::HandleException.new(2, "Service not found") }
        expect { subject.resolve_handle(bad_handle) }.to raise_error(Handle::HandleError)
      end

      it "#create_record" do
        new_record = subject.create_record(new_handle)
        expect(new_record.connection).to eq(subject)
        expect(new_record.handle).to eq(new_handle)
      end

      it "#create_handle" do
        server.should_receive(:createHandle).with(new_handle, anything()) { true }
        expect(subject.create_handle(new_handle, record)).to be_true
      end

      it "#add_handle_values" do
        server.should_receive(:addHandleValues).with(new_handle, anything()) { true }
        expect(subject.add_handle_values(new_handle, record)).to be_true
      end

      it "#update_handle_values" do
        server.should_receive(:updateHandleValues).with(new_handle, anything()) { true }
        expect(subject.update_handle_values(new_handle, record)).to be_true
      end

      it "#delete_handle_values" do
        server.should_receive(:deleteHandleValues).with(new_handle, anything()) { true }
        expect(subject.delete_handle_values(new_handle, record)).to be_true
      end

      it "#delete_handle" do
        server.should_receive(:deleteHandle).with(new_handle) { true }
        expect(subject.delete_handle(new_handle)).to be_true
      end
    end
  end
end