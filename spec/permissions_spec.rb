require File.expand_path('../spec_helper',__FILE__)

describe Handle::Permissions do
  subject { Handle::Permissions.new :foo, :bar, :baz, :quux, 0b0110 }

  it "initialize" do
    expect(subject.bitmask).to eq(0b110)
    expect(subject.read(:foo)).to be false
    expect(subject.read(:bar)).to be true
    expect(subject.read(:baz)).to be true
    expect(subject.read(:quux)).to be false
  end

  it "modify" do
    subject.foo = true
    subject.bar = false
    expect(subject.read(:foo)).to be true
    expect(subject.read(:bar)).to be false
    expect(subject.read(:baz)).to be true
    expect(subject.read(:quux)).to be false
  end

  describe "#method_missing" do
    it "handles accessors" do
      expect(subject.foo?).to be false
    end
  end

  it "#to_bool" do
    expect(subject.to_bool).to eq([false, true, true, false])
  end

  it "#to_bool" do
    expect(subject.to_s).to eq('0110')
  end

  it "#inspect" do
    expect(subject.inspect).to eq("[:bar, :baz]")
  end

  it "dispatches" do
    expect { subject.foo    }.to raise_error(NameError)
    expect { subject.foobar }.to raise_error(NameError)
  end
end
