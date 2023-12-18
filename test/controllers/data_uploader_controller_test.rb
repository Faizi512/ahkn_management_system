require "test_helper"

class DataUploaderControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get data_uploader_new_url
    assert_response :success
  end

  test "should get create" do
    get data_uploader_create_url
    assert_response :success
  end
end
