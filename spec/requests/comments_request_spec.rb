require 'spec_helper'

describe "Comments request" do
  it "creates and replies when not signed in" do
    episode = Factory(:episode, :name => "Blast from the Past")
    visit episode_path(episode)
    click_on "0 Comments"
    click_on "sign in through GitHub"
    page.should have_content("New comment")
    click_on "Post Comment"
    page.should have_content("Invalid Fields")
    fill_in "comment_content", :with => "Hello world!"
    click_on "Post Comment"
    page.should have_content("Blast from the Past")
    page.should have_content("Hello world!")
    click_on "Reply"
    fill_in "comment_content", :with => "Hello back."
    click_on "Post Comment"
    page.should have_content("Hello back.")
  end

  it "creates when banned" do
    login Factory(:user, :banned_at => Time.now)
    visit episode_path(Factory(:episode), :view => "comments")
    page.should have_content("banned")
  end

  it "updates a comment" do
    user = Factory(:user, :admin => true)
    login user
    episode = Factory(:episode, :name => "Blast from the Past")
    comment = Factory(:comment, :content => "Hello world!", :episode_id => episode.id)
    visit episode_path(episode, :view => "comments")
    click_on "Edit"
    fill_in "comment_content", :with => ""
    click_on "Update Comment"
    page.should have_content("Invalid Fields")
    fill_in "comment_content", :with => "Hello back."
    click_on "Update Comment"
    page.should have_content("Hello back.")
    comment.versions(true).size.should eq(2)
    comment.versions.last.whodunnit.to_i.should eq(user.id)
  end

  it "destroys a comment" do
    login Factory(:user, :admin => true)
    episode = Factory(:episode, :name => "Blast from the Past")
    Factory(:comment, :content => "Hello world!", :episode_id => episode.id)
    visit episode_path(episode, :view => "comments")
    click_on "Delete"
    page.should_not have_content("Hello world!")
  end
end
