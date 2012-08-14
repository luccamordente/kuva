# coding: utf-8
require 'spec_helper'

describe UserDecorator do
  let(:user) { User.new.extend UserDecorator }
  subject { user }
end
