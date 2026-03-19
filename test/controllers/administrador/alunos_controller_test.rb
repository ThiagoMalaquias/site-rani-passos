require 'test_helper'

class Administrador::AlunosControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get administrador_alunos_index_url
    assert_response :success
  end

end
