require 'rails_helper'
require 'rspec/expectations'

describe "Comment class should be there" do
  it do 
  comment = Comment.new
  expect(comment.nil?).to be_falsey
  end
end


