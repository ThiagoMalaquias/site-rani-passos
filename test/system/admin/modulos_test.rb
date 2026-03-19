require "application_system_test_case"

class Administrador::ModulosTest < ApplicationSystemTestCase
  setup do
    @admin_modulo = admin_modulos(:one)
  end

  test "visiting the index" do
    visit admin_modulos_url
    assert_selector "h1", text: "Admin/Modulos"
  end

  test "creating a Modulo" do
    visit admin_modulos_url
    click_on "New Admin/Modulo"

    fill_in "Descricao", with: @admin_modulo.descricao
    fill_in "Nome", with: @admin_modulo.nome
    fill_in "Tempo", with: @admin_modulo.tempo
    click_on "Create Modulo"

    assert_text "Modulo was successfully created"
    click_on "Back"
  end

  test "updating a Modulo" do
    visit admin_modulos_url
    click_on "Edit", match: :first

    fill_in "Descricao", with: @admin_modulo.descricao
    fill_in "Nome", with: @admin_modulo.nome
    fill_in "Tempo", with: @admin_modulo.tempo
    click_on "Update Modulo"

    assert_text "Modulo was successfully updated"
    click_on "Back"
  end

  test "destroying a Modulo" do
    visit admin_modulos_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Modulo was successfully destroyed"
  end
end
