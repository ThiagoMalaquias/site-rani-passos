require "application_system_test_case"

class Administrador::SoftskillsTest < ApplicationSystemTestCase
  setup do
    @administrador_softskill = administrador_softskills(:one)
  end

  test "visiting the index" do
    visit administrador_softskills_url
    assert_selector "h1", text: "Administrador/Softskills"
  end

  test "creating a Softskill" do
    visit administrador_softskills_url
    click_on "New Administrador/Softskill"

    fill_in "Nome", with: @administrador_softskill.nome
    click_on "Create Softskill"

    assert_text "Softskill was successfully created"
    click_on "Back"
  end

  test "updating a Softskill" do
    visit administrador_softskills_url
    click_on "Edit", match: :first

    fill_in "Nome", with: @administrador_softskill.nome
    click_on "Update Softskill"

    assert_text "Softskill was successfully updated"
    click_on "Back"
  end

  test "destroying a Softskill" do
    visit administrador_softskills_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Softskill was successfully destroyed"
  end
end
