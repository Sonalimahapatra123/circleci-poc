class Comment < ApplicationRecord
  belongs_to :post
  delegate :title, :body, :to => :post, :prefix => true
end
