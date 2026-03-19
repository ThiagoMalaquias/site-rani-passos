require "application_system_test_case"

class Administrador::AdministradorsTest < ApplicationSystemTestCase
  setup do
    @admin_administrador = admin_administradors(:one)
  end

  test "visiting the index" do
    visit admin_administradors_url
    assert_selector "h1", text: "Admin/Administradors"
  end

  test "creating a Administrador" do
    visit admin_administradors_url
    click_on "New Admin/Administrador"

    fill_in "Email", with: @admin_administrador.email
    fill_in "Endereco", with: @admin_administrador.endereco
    fill_in "Nome", with: @admin_administrador.nome
    fill_in "Password", with: @admin_administrador.password
    fill_in "Password digest", with: @admin_administrador.password_digest
    fill_in "Telefone", with: @admin_administrador.telefone
    click_on "Create Administrador"

    assert_text "Administrador was successfully created"
    click_on "Back"
  end

  test "updating a Administrador" do
    visit admin_administradors_url
    click_on "Edit", match: :first

    fill_in "Email", with: @admin_administrador.email
    fill_in "Endereco", with: @admin_administrador.endereco
    fill_in "Nome", with: @admin_administrador.nome
    fill_in "Password", with: @admin_administrador.password
    fill_in "Password digest", with: @admin_administrador.password_digest
    fill_in "Telefone", with: @admin_administrador.telefone
    click_on "Update Administrador"

    assert_text "Administrador was successfully updated"
    click_on "Back"
  end

  test "destroying a Administrador" do
    visit admin_administradors_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Administrador was successfully destroyed"
  end
end
