require 'test_helper'

class Administrador::ConfiguracaosControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get administrador_configuracaos_index_url
    assert_response :success
  end

end
