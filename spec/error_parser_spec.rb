require 'spec_helper'

describe 'Handle::ErrorParser', unless: jruby? do
  subject { Handle::ErrorParser.failure_message(raw_line) }

  context "A failure with 3 parts" do
    let(:raw_line) { '==>FAILURE[7]: create:10427.TEST/000001: No authentication info provided' }

    it { is_expected.to eq 'No authentication info provided' }
  end

  context "A failure with 4 parts" do
    let(:raw_line) { "==>FAILURE[7]: create:10427.TEST/000001: Error(101): HANDLE ALREADY EXISTS" }

    it { is_expected.to eq 'HANDLE ALREADY EXISTS' }
  end
end
