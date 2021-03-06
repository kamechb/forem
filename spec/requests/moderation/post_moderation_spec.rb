require 'spec_helper'
describe "moderation" do
  let(:forum) { Factory(:forum) }
  let(:user) { Factory(:user) }

  context "of posts" do
    let!(:moderator) { Factory(:user, :login => "moderator") }
    let!(:group) do
      group = Factory(:group)
      group.members << moderator
      group.save!
      group
    end

    let!(:forum) { Factory(:forum) }
    let!(:topic) { Factory(:topic, :forum => forum) }
    let!(:post) { Factory(:post, :topic => topic) }

    before do
      forum.moderators << group
      sign_in(moderator)
      topic.approve!
    end

    context "mass moderation" do
      it "can approve a post by a new user" do

        visit forum_path(forum)
        click_link "Moderation Tools"

        choose "Approve"
        click_button "Moderate"

        flash_notice!("The selected posts have been moderated.")
        post.reload
        post.should be_approved
        post.user.reload.forem_state.should == "approved"
      end

      it "can mark a post as spam" do
        visit forum_path(forum)
        click_link "Moderation Tools"

        choose "Spam"
        click_button "Moderate"
        flash_notice!("The selected posts have been moderated.")
        post.reload
        post.should be_spam
        post.user.reload.forem_state.should == "spam"
      end
    end

    context "singular moderation" do
      it "can approve a post by a new user" do
        visit forum_topic_path(forum, topic)
        choose "Approve"
        click_button "Moderate"

        flash_notice!("The selected posts have been moderated.")
        post.user.reload.forem_state.should == "approved"
      end
    end
  end
end
