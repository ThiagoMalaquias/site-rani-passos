require "application_system_test_case"

class Administrador::LinguagensTest < ApplicationSystemTestCase
  setup do
    @administrador_linguagen = administrador_linguagens(:one)
  end

  test "visiting the index" do
    visit administrador_linguagens_url
    assert_selector "h1", text: "Administrador/Linguagens"
  end

  test "creating a Linguagen" do
    visit administrador_linguagens_url
    click_on "New Administrador/Linguagen"

    fill_in "Nome", with: @administrador_linguagen.nome
    click_on "Create Linguagen"

    assert_text "Linguagen was successfully created"
    click_on "Back"
  end

  test "updating a Linguagen" do
    visit administrador_linguagens_url
    click_on "Edit", match: :first

    fill_in "Nome", with: @administrador_linguagen.nome
    click_on "Update Linguagen"

    assert_text "Linguagen was successfully updated"
    click_on "Back"
  end

  test "destroying a Linguagen" do
    visit administrador_linguagens_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Linguagen was successfully destroyed"
  end
end
