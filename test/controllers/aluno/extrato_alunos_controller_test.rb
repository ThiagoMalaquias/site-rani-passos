require 'test_helper'

class Aluno::ExtratoAlunosControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get aluno_extrato_alunos_index_url
    assert_response :success
  end

end
