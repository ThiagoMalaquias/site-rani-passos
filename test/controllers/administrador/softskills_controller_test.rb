require 'test_helper'

class Administrador::SoftskillsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @administrador_softskill = administrador_softskills(:one)
  end

  test "should get index" do
    get administrador_softskills_url
    assert_response :success
  end

  test "should get new" do
    get new_administrador_softskill_url
    assert_response :success
  end

  test "should create administrador_softskill" do
    assert_difference('Administrador::Softskill.count') do
      post administrador_softskills_url, params: { administrador_softskill: { nome: @administrador_softskill.nome } }
    end

    assert_redirected_to administrador_softskill_url(Administrador::Softskill.last)
  end

  test "should show administrador_softskill" do
    get administrador_softskill_url(@administrador_softskill)
    assert_response :success
  end

  test "should get edit" do
    get edit_administrador_softskill_url(@administrador_softskill)
    assert_response :success
  end

  test "should update administrador_softskill" do
    patch administrador_softskill_url(@administrador_softskill), params: { administrador_softskill: { nome: @administrador_softskill.nome } }
    assert_redirected_to administrador_softskill_url(@administrador_softskill)
  end

  test "should destroy administrador_softskill" do
    assert_difference('Administrador::Softskill.count', -1) do
      delete administrador_softskill_url(@administrador_softskill)
    end

    assert_redirected_to administrador_softskills_url
  end
end
