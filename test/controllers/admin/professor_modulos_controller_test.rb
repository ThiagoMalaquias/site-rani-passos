require 'test_helper'

class Administrador::ProfessorModulosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_professor_modulo = admin_professor_modulos(:one)
  end

  test "should get index" do
    get admin_professor_modulos_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_professor_modulo_url
    assert_response :success
  end

  test "should create admin_professor_modulo" do
    assert_difference('Administrador::ProfessorModulo.count') do
      post admin_professor_modulos_url, params: { admin_professor_modulo: { modulo_id: @admin_professor_modulo.modulo_id, professor_id: @admin_professor_modulo.professor_id, valor: @admin_professor_modulo.valor } }
    end

    assert_redirected_to admin_professor_modulo_url(Administrador::ProfessorModulo.last)
  end

  test "should show admin_professor_modulo" do
    get admin_professor_modulo_url(@admin_professor_modulo)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_professor_modulo_url(@admin_professor_modulo)
    assert_response :success
  end

  test "should update admin_professor_modulo" do
    patch admin_professor_modulo_url(@admin_professor_modulo), params: { admin_professor_modulo: { modulo_id: @admin_professor_modulo.modulo_id, professor_id: @admin_professor_modulo.professor_id, valor: @admin_professor_modulo.valor } }
    assert_redirected_to admin_professor_modulo_url(@admin_professor_modulo)
  end

  test "should destroy admin_professor_modulo" do
    assert_difference('Administrador::ProfessorModulo.count', -1) do
      delete admin_professor_modulo_url(@admin_professor_modulo)
    end

    assert_redirected_to admin_professor_modulos_url
  end
end
