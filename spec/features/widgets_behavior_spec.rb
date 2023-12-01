require 'rails_helper'

describe 'interaction for WidgetsController' do
  include HotGlue::ControllerHelper
  include ActionView::RecordIdentifier

    # HOTGLUE-SAVESTART
  # HOTGLUE-END
  let(:current_user) {create(:user)}

  let!(:widget1) {
    widget = create(:widget, user: current_user , 
                          name: FFaker::Movie.title )

    widget.save!
    widget
  }
 
  before do
    login_as(current_user)
  end  
  describe "index" do
    it "should show me the list" do
      visit widgets_path
      expect(page).to have_content(widget1.name)
    end
  end

  describe "new & create" do
    it "should create a new Widget" do
      visit widgets_path
      click_link "New Widget"
      expect(page).to have_selector(:xpath, './/h3[contains(., "New Widget")]')
      new_name = FFaker::Movie.title 
      find("[name='widget[name]']").fill_in(with: new_name)
      click_button "Save"
      expect(page).to have_content("Successfully created")

      expect(page).to have_content(new_name)
    end
  end


  describe "edit & update" do
    it "should return an editable form" do
      visit widgets_path
      find("a.edit-widget-button[href='/widgets/#{widget1.id}/edit']").click

      expect(page).to have_content("Editing #{widget1.name.squish || "(no name)"}")
      new_name = FFaker::Movie.title 
      find("[name='widget[name]']").fill_in(with: new_name)
      click_button "Save"
      within("turbo-frame#__#{dom_id(widget1)} ") do
        expect(page).to have_content(new_name)
      end
    end
  end 

  describe "destroy" do
    it "should destroy" do
      visit widgets_path
      accept_alert do
        find("form[action='/widgets/#{widget1.id}'] > input.delete-widget-button").click
      end
      expect(page).to_not have_content(widget1.name)
      expect(Widget.where(id: widget1.id).count).to eq(0)
    end
  end
end

