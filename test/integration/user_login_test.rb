require 'test_helper'

class UserLoginTest < ActionDispatch::IntegrationTest
  include Capybara::DSL
  attr_reader :user

  def setup
    @user = User.create(username: "name", password: "password")
    visit root_url
  end

  test 'a user can login' do
    fill_in "session[username]", with: "name"
    fill_in "session[password]", with: "password"
    click_link_or_button "Login"
    within('#banner') do
      assert page.has_content?("Welcome name")
    end
  end

  test 'an unregistered user cannot login' do
   click_link_or_button "Login"
   within('#flash_errors') do
     assert page.has_content?("Invalid")
   end
  end

  test 'a user has associated ideas' do
    @idea = Idea.create(title: "idea", description: "description", user_id: user.id)
      ApplicationController.any_instance.stubs(:current_user).returns(user)
      visit user_path(user)
      within('#ideas') do
        assert page.has_content?("description")
        assert page.has_content?("idea")
      end
    end


  test 'a registered user can logout' do
    ApplicationController.any_instance.stubs(:current_user).returns(user)
    click_link_or_button "Logout"
    within('#flash_notice') do
      assert page.has_content?("Logged out")
    end
  end

  test 'registered user cannot view a another users profile' do
    ApplicationController.any_instance.stubs(:current_user).returns(user)
    user2 = User.create(username: "protected", password: "password", password_confirmation: "password")
    visit user_path(user2)
    within('#flash_alert') do
      assert page.has_content?("not authorized")
    end
  end

  test 'an admin user can login' do
    skip
    admin_user = User.create(username: "protected", password: "password", password_confirmation: "password", role: "admin")
    visit root_path
    fill_in "session[username]", with: "protected"
    fill_in "session[password]", with: "password"
    click_link_or_button "Login"
    within("#admin") do
      assert page.has_content?("Welcome Admin")
    end
  end
end
