class RewriteDocument < ActiveRecord::Base
  belongs_to :document
  belongs_to :report
end
