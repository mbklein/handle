require File.expand_path('../spec_helper',__FILE__)

describe Handle::Field do
  let(:handle_str)  { Handle::Field::Base.from_data(' index=2 ttl=15200 type=URL rwr- "http://www.example.edu/fake-handle"') }
  let(:handle_hash) { Handle::Field::Base.from_data({ index: 2, ttl: 15200, type: 'URL', perms: 14, value: 'http://www.example.edu/fake-handle' }) }

  it "#from_hash" do
    handle = handle_hash
    expect(handle).to be_a(Handle::Field::URL)
    expect(handle.class.value_type).to eq('URL')
    expect(handle.ttl).to eq(15200)
    expect(handle.value).to eq('http://www.example.edu/fake-handle')
    expect(handle.value_str).to eq('http://www.example.edu/fake-handle')
  end

  it "#from_string" do
    handle = handle_str
    expect(handle).to be_a(Handle::Field::URL)
    expect(handle.class.value_type).to eq('URL')
    expect(handle.ttl).to eq(15200)
    expect(handle.value).to eq('http://www.example.edu/fake-handle')
    expect(handle.value_str).to eq('http://www.example.edu/fake-handle')
  end

  it "#to_hash" do
    h = handle_str.to_h
    expect(h).to be_a(Hash)
    expect(h).to eq({
      index: 2,
      type:  'URL',
      ttl:   15200,
      perms: 14,
      value: 'http://www.example.edu/fake-handle'
    })
  end

  it "#to_s" do
    expect(handle_hash.to_s).to eq(handle_str.to_s)
  end
end
