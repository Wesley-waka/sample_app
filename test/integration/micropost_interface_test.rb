require "test_helper"

class MicropostInterfaceTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
    log_in_as(@user)
  end

  test "should paginate microposts" do
    get root_path
    assert_select 'div.pagination'
  end

  # Invalid submission
  test "should show errors but not create micropost on invalid submission" do
    content = "This is a valid content"  # Define content here
    assert_no_difference 'Micropost.count' do
      post microposts_path, micropost: { content: content }
    end
    post microposts_path, micropost: { content: "" }
    assert_select 'div#error_explanation'
    assert_select 'a[href=?]', '/?page=2' # correct pagination link
  end

  # Valid Submission
  test "should create a micropost on valid submission" do
    content = "This micropost really ties the room together"
    assert_difference 'Micropost.count', 1 do
      post microposts_path, micropost: { content: content }
    end
    assert_redirected_to root_url
    follow_redirect!
    assert_match content, response.body
  end

  # Delete a post
  test "should have a micropost delete link on own profile page" do
    get users_path(@user)
    assert_select 'a', text: 'delete'
  end

  test "should be able to delete own micropost" do
    first_micropost = @user.microposts.paginate(page: 1).first
    assert_difference 'Micropost.count', -1 do
      delete micropost_path(first_micropost)
    end
  end

  # Visit a different user
  test "should not have delete links on other user's profile page" do
    get user_path(users(:archer))
    assert_select 'a', text: 'delete', count: 0
  end
end
