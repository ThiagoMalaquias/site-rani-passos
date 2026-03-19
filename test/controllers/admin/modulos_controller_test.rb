require 'test_helper'

class Administrador::ModulosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_modulo = admin_modulos(:one)
  end

  test "should get index" do
    get admin_modulos_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_modulo_url
    assert_response :success
  end

  test "should create admin_modulo" do
    assert_difference('Administrador::Modulo.count') do
      post admin_modulos_url, params: { admin_modulo: { descricao: @admin_modulo.descricao, nome: @admin_modulo.nome, tempo: @admin_modulo.tempo } }
    end

    assert_redirected_to admin_modulo_url(Administrador::Modulo.last)
  end

  test "should show admin_modulo" do
    get admin_modulo_url(@admin_modulo)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_modulo_url(@admin_modulo)
    assert_response :success
  end

  test "should update admin_modulo" do
    patch admin_modulo_url(@admin_modulo), params: { admin_modulo: { descricao: @admin_modulo.descricao, nome: @admin_modulo.nome, tempo: @admin_modulo.tempo } }
    assert_redirected_to admin_modulo_url(@admin_modulo)
  end

  test "should destroy admin_modulo" do
    assert_difference('Administrador::Modulo.count', -1) do
      delete admin_modulo_url(@admin_modulo)
    end

    assert_redirected_to admin_modulos_url
  end
end
