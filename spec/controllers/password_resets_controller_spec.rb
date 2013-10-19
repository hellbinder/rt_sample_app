require 'spec_helper'

describe PasswordResetsController do
  let(:user) { FactoryGirl.create :user }
  before { visit new_password_reset_path }
end
