require 'test_helper'

class ExtratoProfessorControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get extrato_professor_index_url
    assert_response :success
  end

end
