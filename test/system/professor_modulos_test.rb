require "application_system_test_case"

class ProfessorModulosTest < ApplicationSystemTestCase
  setup do
    @professor_modulo = professor_modulos(:one)
  end

  test "visiting the index" do
    visit professor_modulos_url
    assert_selector "h1", text: "Professor Modulos"
  end

  test "creating a Professor modulo" do
    visit professor_modulos_url
    click_on "New Professor Modulo"

    fill_in "Modulo", with: @professor_modulo.modulo_id
    fill_in "Professor", with: @professor_modulo.professor_id
    click_on "Create Professor modulo"

    assert_text "Professor modulo was successfully created"
    click_on "Back"
  end

  test "updating a Professor modulo" do
    visit professor_modulos_url
    click_on "Edit", match: :first

    fill_in "Modulo", with: @professor_modulo.modulo_id
    fill_in "Professor", with: @professor_modulo.professor_id
    click_on "Update Professor modulo"

    assert_text "Professor modulo was successfully updated"
    click_on "Back"
  end

  test "destroying a Professor modulo" do
    visit professor_modulos_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Professor modulo was successfully destroyed"
  end
end
