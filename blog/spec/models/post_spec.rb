require 'rails_helper'
require 'rspec/expectations'

describe "Post class should be there" do
  it do
  post = Post.new
  expect(post.nil?).to be_falsey
  end
end


