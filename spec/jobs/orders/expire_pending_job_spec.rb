require "rails_helper"

RSpec.describe Orders::ExpirePendingJob, type: :job do
  it "calls the ExpirePending service" do
    service = instance_double(Orders::ExpirePending, call: 0)
    allow(Orders::ExpirePending).to receive(:new).and_return(service)

    described_class.perform_now

    expect(service).to have_received(:call)
  end
end
