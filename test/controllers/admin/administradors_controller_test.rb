require 'test_helper'

class Administrador::AdministradorsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_administrador = admin_administradors(:one)
  end

  test "should get index" do
    get admin_administradors_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_administrador_url
    assert_response :success
  end

  test "should create admin_administrador" do
    assert_difference('Administrador::Administrador.count') do
      post admin_administradors_url, params: { admin_administrador: { email: @admin_administrador.email, endereco: @admin_administrador.endereco, nome: @admin_administrador.nome, password: @admin_administrador.password, password_digest: @admin_administrador.password_digest, telefone: @admin_administrador.telefone } }
    end

    assert_redirected_to admin_administrador_url(Administrador::Administrador.last)
  end

  test "should show admin_administrador" do
    get admin_administrador_url(@admin_administrador)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_administrador_url(@admin_administrador)
    assert_response :success
  end

  test "should update admin_administrador" do
    patch admin_administrador_url(@admin_administrador), params: { admin_administrador: { email: @admin_administrador.email, endereco: @admin_administrador.endereco, nome: @admin_administrador.nome, password: @admin_administrador.password, password_digest: @admin_administrador.password_digest, telefone: @admin_administrador.telefone } }
    assert_redirected_to admin_administrador_url(@admin_administrador)
  end

  test "should destroy admin_administrador" do
    assert_difference('Administrador::Administrador.count', -1) do
      delete admin_administrador_url(@admin_administrador)
    end

    assert_redirected_to admin_administradors_url
  end
end
