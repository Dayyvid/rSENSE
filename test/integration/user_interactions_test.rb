# Put tests based on how the user interacts with the site here.
# Not every test needs its own file. However, if one feature has a lot of tests
# on this page, consider moving it to its own file.
require 'test_helper'
require_relative 'base_integration_test'

class UserInteractionsTest < IntegrationTest
  self.use_transactional_fixtures = false

  setup do
    @slick_project = projects(:slickgrid_project)
    @timeline_project = projects(:timeline_vis_disable)
    @commas_project = projects(:template_escape_commas)
  end

  test 'edit button should not show on projects you don\'t own' do
    visit project_path(@slick_project)
    assert page.has_no_content?('Edit'), 'Edit button appears on project without being logged in'
    login('pson@cs.uml.edu', '12345')
    visit project_path(@slick_project)
    assert page.has_no_content?('Edit'), 'Edit button appears on project that the user does not own.'
  end

  test 'try to inject code into data set' do
    # Make sure that code injection cannot happen anymore
    login('pson@cs.uml.edu', '12345')

    click_on 'Projects'
    find('#create-project-fab-button').click
    find('#project_title').set('Code Injection Test')
    click_on 'Create Project'

    find('#manual_fields').click
    click_on 'Add Text'
    fill_in 'text_1', with: '<script>alert(1)</script>'
    click_on 'Save and Return'

    assert page.has_no_content?('<script>'), 'Users should not be able to inject code into the webpage.'

    click_on 'Manual Entry'
    first('.editor-text').set('<h1>Testing...</h1>')
    find('#edit_table_save_2').click

    assert page.has_no_content?('<h1>'), 'Users should not be able to inject code into the webpage.'
  end

  test 'delete project with data sets' do
    login('pson@cs.uml.edu', '12345')
    visit project_path(@timeline_project)

    find('#edit-project-button').click
    click_on 'Delete Project'
    assert page.has_content?("Can't delete project with data sets"), 'Error message not given.'
  end

  test 'upload CSV containing commas' do
    login('pson@cs.uml.edu', '12345')
    visit project_path(@commas_project)
    csv_path = Rails.root.join('test', 'CSVs', 'commas.csv')

    find(:css, '#template_file_form').attach_file('file', csv_path)
    assert page.has_content?('Please select types for each field below.'), "Didn't find upload button"
    find('#create_dataset').click
    click_on 'Submit'
    visit project_path(@commas_project)
    assert page.has_content?('Last Name, First Name'), 'Field names were split at comma.'

    find(:css, '#datafile_form').attach_file('file', csv_path)
    assert page.has_content?('Match Quality'), "Didn't find upload button"
    click_on 'Submit'
    visit project_path(@commas_project)

    find('.data_set_edit').click
    assert page.has_content?('Son, Patrick'), 'Text data was split up at comma.'
  end
end
