require File.expand_path('../spec_helper',__FILE__)

describe Handle::Record do
  let(:data) { %{ index=2 type=URL rwr- "http://www.example.edu/fake-handle"\n index=6 type=EMAIL rwr- "handle@example.edu"\n index=100 type=HS_ADMIN rw-- "0FFF0000000D302E4E412F46414B452E41444D494E0000012C"} }

  describe "deserialize" do
    it "should load from a string" do
      record = Handle::Record.from_data(data)
      expect(record).to be_a(Handle::Record)
      expect(record.length).to eq(3)
      expect(record[0].value).to eq('http://www.example.edu/fake-handle')
      expect(record[1].value).to eq('handle@example.edu')
      expect(record[2].admin_handle).to eq('0.NA/FAKE.ADMIN')
    end

    it "should load from an array" do
      record = Handle::Record.from_data(data.lines.to_a)
      expect(record).to be_a(Handle::Record)
      expect(record.length).to eq(3)
      expect(record[0].value).to eq('http://www.example.edu/fake-handle')
      expect(record[1].value).to eq('handle@example.edu')
      expect(record[2].admin_handle).to eq('0.NA/FAKE.ADMIN')
    end
  end

  describe "methods" do
    subject { Handle::Record.from_data(data) }
    it "#add" do
      new_field = subject.add(:URN, 'info:example:content')
      expect(subject.length).to eq(4)
      expect(new_field.value).to eq('info:example:content')
    end

    it "#find_by_index" do
      expect(subject.find_by_index(6).value).to eq('handle@example.edu')
      expect(subject.find_by_index(1)).to be_nil
    end
  end

  describe "building" do
    let(:this) {
      record = Handle::Record.new
      record.add(:URL, 'http://www.example.edu/fake-handle').index = 2
      record.add(:Email, 'handle@example.edu').index = 6
      record << Handle::Field::HSAdmin.new('0.NA/FAKE.ADMIN')
      record
    }

    let(:that) {
      record = Handle::Record.new
      record.add(:URN, 'info:example:content')
      record.add(:URL, 'http://www.example.edu/fake-handle').index = 2
      record << Handle::Field::HSAdmin.new('0.NA/FAKE.ADMIN')
      record
    }

    it "should have the correct content" do
      expect(this).to be_a(Handle::Record)
      expect(this.length).to eq(3)
      expect(this[0].value).to eq('http://www.example.edu/fake-handle')
      expect(this[1].value).to eq('handle@example.edu')
      expect(this[2].admin_handle).to eq('0.NA/FAKE.ADMIN')
    end

    it "should diff correctly" do
      diff = this | that
      expect(diff[:add].length).to eq(1)
      expect(diff[:delete].length).to eq(1)
      expect(diff[:update].length).to eq(2)
    end
  end
end