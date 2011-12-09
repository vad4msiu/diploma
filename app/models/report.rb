class Report < ActiveRecord::Base
  belongs_to :user

  state_machine :state, :initial => :new do
    event :process do
      transition :new => :processed
    end

    event :complite do
      transition :processed => :complited
    end
  end
end