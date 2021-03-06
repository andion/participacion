require 'rails_helper'

feature 'Managed User' do

  background do
    login_as_manager
  end

  context "Currently managed user" do

    scenario "User is already level three verified" do
      user = create(:user, :level_three)

      visit management_document_verifications_path
      fill_in 'document_verification_document_number', with: user.document_number
      click_button 'Check'

      expect(page).to have_content "already verified"

      within(".account-info") do
        expect(page).to have_content "Identified as"
        expect(page).to have_content "#{user.username}"
        expect(page).to have_content "#{user.email}"
        expect(page).to have_content "#{user.document_number}"
      end
    end

    scenario "User becomes verified as level three" do
      user = create(:user, :level_two)

      visit management_document_verifications_path
      fill_in 'document_verification_document_number', with: user.document_number
      click_button 'Check'

      expect(page).to have_content "Vote proposals"

      click_button 'Verify'

      expect(page).to have_content "already verified"

      within(".account-info") do
        expect(page).to have_content "Identified as"
        expect(page).to have_content "#{user.username}"
        expect(page).to have_content "#{user.email}"
        expect(page).to have_content "#{user.document_number}"
      end
    end

    scenario "User becomes verified as level two (pending email confirmation for level three)" do
      login_as_manager

      user = create(:user)

      visit management_document_verifications_path
      fill_in 'document_verification_document_number', with: '1234'
      click_button 'Check'

      expect(page).to have_content "Please introduce the email used on the account"

      fill_in 'email_verification_email', with: user.email
      click_button 'Send verification email'

      expect(page).to have_content("In order to completely verify this user, it is necessary that the user clicks on a link")

      within(".account-info") do
        expect(page).to have_content "Identified as"
        expect(page).to have_content "#{user.username}"
        expect(page).to have_content "#{user.email}"
        expect(page).to have_content "#{user.document_number}"
      end
    end

    scenario "User is created as level three from scratch" do
      login_as_manager

      visit management_document_verifications_path
      fill_in 'document_verification_document_number', with: '1234'
      click_button 'Check'

      expect(page).to have_content "Please introduce the email used on the account"

      click_link 'Create a new account'

      fill_in 'user_username', with: 'pepe'
      fill_in 'user_email', with: 'pepe@gmail.com'

      click_button 'Create user'

      expect(page).to have_content "We have sent an email"

      user = User.last
      within(".account-info") do
        expect(page).to have_content "Identified as"
        expect(page).to have_content "#{user.username}"
        expect(page).to have_content "#{user.email}"
        expect(page).to have_content "#{user.document_number}"
      end
    end
  end

  scenario "Close the currently managed user session" do
    user = create(:user, :level_three)

    visit management_document_verifications_path
    fill_in 'document_verification_document_number', with: user.document_number
    click_button 'Check'

    expect(page).to have_content "already verified"

    within(".account-info") do
      expect(page).to have_content "Identified as"
      expect(page).to have_content "#{user.username}"

      click_link "Change user"
    end

    expect(page).to have_content "User session signed out successfully."
    expect(current_path).to eq(management_root_path)
  end

end