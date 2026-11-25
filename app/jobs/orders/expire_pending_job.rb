module Orders
  class ExpirePendingJob < ApplicationJob
    queue_as :default

    def perform
      Orders::ExpirePending.new.call
    end
  end
end
