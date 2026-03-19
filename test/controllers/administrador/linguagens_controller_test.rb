require 'test_helper'

class Administrador::LinguagensControllerTest < ActionDispatch::IntegrationTest
  setup do
    @administrador_linguagen = administrador_linguagens(:one)
  end

  test "should get index" do
    get administrador_linguagens_url
    assert_response :success
  end

  test "should get new" do
    get new_administrador_linguagen_url
    assert_response :success
  end

  test "should create administrador_linguagen" do
    assert_difference('Administrador::Linguagen.count') do
      post administrador_linguagens_url, params: { administrador_linguagen: { nome: @administrador_linguagen.nome } }
    end

    assert_redirected_to administrador_linguagen_url(Administrador::Linguagen.last)
  end

  test "should show administrador_linguagen" do
    get administrador_linguagen_url(@administrador_linguagen)
    assert_response :success
  end

  test "should get edit" do
    get edit_administrador_linguagen_url(@administrador_linguagen)
    assert_response :success
  end

  test "should update administrador_linguagen" do
    patch administrador_linguagen_url(@administrador_linguagen), params: { administrador_linguagen: { nome: @administrador_linguagen.nome } }
    assert_redirected_to administrador_linguagen_url(@administrador_linguagen)
  end

  test "should destroy administrador_linguagen" do
    assert_difference('Administrador::Linguagen.count', -1) do
      delete administrador_linguagen_url(@administrador_linguagen)
    end

    assert_redirected_to administrador_linguagens_url
  end
end
