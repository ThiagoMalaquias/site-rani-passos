require "application_system_test_case"

class Administrador::ProfessorsTest < ApplicationSystemTestCase
  setup do
    @admin_professor = admin_professors(:one)
  end

  test "visiting the index" do
    visit admin_professors_url
    assert_selector "h1", text: "Admin/Professors"
  end

  test "creating a Professor" do
    visit admin_professors_url
    click_on "New Admin/Professor"

    fill_in "Bairro", with: @admin_professor.bairro
    fill_in "Cep", with: @admin_professor.cep
    fill_in "Cidade", with: @admin_professor.cidade
    fill_in "Email", with: @admin_professor.email
    fill_in "Endereco", with: @admin_professor.endereco
    fill_in "Nome", with: @admin_professor.nome
    fill_in "Password", with: @admin_professor.password
    fill_in "Password digest", with: @admin_professor.password_digest
    fill_in "Uf", with: @admin_professor.uf
    click_on "Create Professor"

    assert_text "Professor was successfully created"
    click_on "Back"
  end

  test "updating a Professor" do
    visit admin_professors_url
    click_on "Edit", match: :first

    fill_in "Bairro", with: @admin_professor.bairro
    fill_in "Cep", with: @admin_professor.cep
    fill_in "Cidade", with: @admin_professor.cidade
    fill_in "Email", with: @admin_professor.email
    fill_in "Endereco", with: @admin_professor.endereco
    fill_in "Nome", with: @admin_professor.nome
    fill_in "Password", with: @admin_professor.password
    fill_in "Password digest", with: @admin_professor.password_digest
    fill_in "Uf", with: @admin_professor.uf
    click_on "Update Professor"

    assert_text "Professor was successfully updated"
    click_on "Back"
  end

  test "destroying a Professor" do
    visit admin_professors_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Professor was successfully destroyed"
  end
end
