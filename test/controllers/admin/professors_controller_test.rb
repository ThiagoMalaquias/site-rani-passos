require 'test_helper'

class Administrador::ProfessorsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_professor = admin_professors(:one)
  end

  test "should get index" do
    get admin_professors_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_professor_url
    assert_response :success
  end

  test "should create admin_professor" do
    assert_difference('Administrador::Professor.count') do
      post admin_professors_url, params: { admin_professor: { bairro: @admin_professor.bairro, cep: @admin_professor.cep, cidade: @admin_professor.cidade, email: @admin_professor.email, endereco: @admin_professor.endereco, nome: @admin_professor.nome, password: @admin_professor.password, password_digest: @admin_professor.password_digest, uf: @admin_professor.uf } }
    end

    assert_redirected_to admin_professor_url(Administrador::Professor.last)
  end

  test "should show admin_professor" do
    get admin_professor_url(@admin_professor)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_professor_url(@admin_professor)
    assert_response :success
  end

  test "should update admin_professor" do
    patch admin_professor_url(@admin_professor), params: { admin_professor: { bairro: @admin_professor.bairro, cep: @admin_professor.cep, cidade: @admin_professor.cidade, email: @admin_professor.email, endereco: @admin_professor.endereco, nome: @admin_professor.nome, password: @admin_professor.password, password_digest: @admin_professor.password_digest, uf: @admin_professor.uf } }
    assert_redirected_to admin_professor_url(@admin_professor)
  end

  test "should destroy admin_professor" do
    assert_difference('Administrador::Professor.count', -1) do
      delete admin_professor_url(@admin_professor)
    end

    assert_redirected_to admin_professors_url
  end
end
