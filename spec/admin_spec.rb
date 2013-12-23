require File.expand_path('../spec_helper',__FILE__)

describe Handle::Field::HSAdmin do
  let(:handle_str)  { Handle::Field::Base.from_data(' index=100 ttl=15200 type=HS_ADMIN rwr- "0FFF0000000D302E4E412F46414B452E41444D494E0000012C"') }
  let(:handle_hash) { Handle::Field::Base.from_data({ index: 100, ttl: 15200, type: 'HS_ADMIN', perms: 14, value: '0FFF0000000D302E4E412F46414B452E41444D494E0000012C' }) }

  it "#from_hash" do
    handle = handle_hash
    expect(handle).to be_a(Handle::Field::HSAdmin)
    expect(handle.class.value_type).to eq('HS_ADMIN')
    expect(handle.ttl).to eq(15200)
    expect(handle.admin_handle).to eq('0.NA/FAKE.ADMIN')
    expect(handle.admin_index).to eq(300)
    expect(handle.admin_perms.bitmask).to eq(4095)
#    expect(handle.value).to eq('http://www.example.edu/fake-handle')
    expect(handle.value_str).to eq('300:111111111111:0.NA/FAKE.ADMIN')
  end

  it "#from_string" do
    handle = handle_str
    expect(handle).to be_a(Handle::Field::HSAdmin)
    expect(handle.class.value_type).to eq('HS_ADMIN')
    expect(handle.ttl).to eq(15200)
    expect(handle.admin_handle).to eq('0.NA/FAKE.ADMIN')
    expect(handle.admin_index).to eq(300)
    expect(handle.admin_perms.bitmask).to eq(4095)
#    expect(handle.value).to eq('http://www.example.edu/fake-handle')
    expect(handle.value_str).to eq('300:111111111111:0.NA/FAKE.ADMIN')
  end

  it "#to_hash" do
    h = handle_str.to_h
    expect(h).to be_a(Hash)
    expect(h).to eq({
      index: 100,
      type:  'HS_ADMIN',
      ttl:   15200,
      perms: 14,
      admin_handle: '0.NA/FAKE.ADMIN',
      admin_index: 300,
      admin_perms: 4095
    })
  end

  it "#to_s" do
    expect(handle_hash.to_s).to eq(handle_str.to_s)
  end
end
