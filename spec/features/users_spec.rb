require "spec_helper"

describe "Users" do

  subject { page }

  let!(:user){ FactoryGirl.create(:user, :github => "http://www.github.com/foobar", :about => "I rock") }
  let!(:other_user) { FactoryGirl.create(:user, email: "other_user@example.com") }
  let!(:project) { FactoryGirl.create(:content_bucket) }
  
  describe "Profile Page (#show)" do

    before do
      user.content_buckets << project
      sign_in(user)
    end

    context "for current user" do
      before do 
        visit user_path(user)
      end

      it "should show the user's name" do
        page.source.should have_selector("h2", :text => user.username)
      end
      it "should show the github profile link" do
        page.source.should have_link(user.github)
      end
      it "should show the about text" do
        page.source.should have_selector("p", :text => user.about)
      end
      it "should list the projects the user is working on" do
        page.source.should have_selector("li", :text => project.name)
      end
      it "should show the edit button" do
        page.source.should have_selector("button", :text => "Edit")
      end

    end

    context "for another user" do
      before { visit user_path(other_user) }

      it "should show that user's name" do
        page.source.should have_selector("h2", :text => other_user.username)
      end
      it "should not have an edit button" do
        page.source.should_not have_selector("button", :text => "Edit")
      end
    end
  end

  describe "Edit Profile Page (#edit)" do

    before do
      sign_in(user)
    end

    context "for not current user" do
      before do
        visit edit_user_path(other_user)
      end

      it "should not allow that edit page to display" do
        current_path.should_not == edit_user_path(other_user)
      end

      it "should redirect to show page for that user" do
        current_path.should == user_path(other_user)
      end
    end

    context "for logged in user" do
      before do
        visit edit_user_path(user)
      end

      it "should allow the edit page to display" do
        current_path.should == edit_user_path(user)
      end

      context "with new data entered" do
        before do
          fill_in "user_facebook", :with => "facebook"
          fill_in "user_about", :with => "New about me"
          click_button "Update"
        end

        it "should go to show page" do
          current_path.should == user_path(user)
        end
        it "should show facebook changes" do
          page.source.should have_link("facebook")
        end
        it "should show about changes" do
          page.source.should have_selector("p", :text => "New about me")
        end
      end
    end
  end

  describe "Users index page" do

    context "after signing in" do
      before do
        sign_in(user)
        visit users_path
      end

      it { should have_selector("h2", :text => "Students") }
      it { should have_link(user.username, :href=>user_path(user)) }
      it { should have_selector("img")}

    end
      
    context "list users" do
      before do
        sign_in(user)        
        visit users_path
      end
      
      # Check to see if we get any listing at all
      it { should have_selector('div.student-info') }
    end
    
    context "list users by most recently active to least" do
        # factory users were assigned a last sign-in time of x weeks by default, in factories.rb
        before do 
        sign_in(user)      # this user should now be the one most recently logged in
        
        # Get all users, in order of most recently logged in, going back
        @users = User.find(:all, :order => "last_sign_in_at DESC")
        end
        
        # it { @users.each { |user| puts user.id, user.username, user.last_sign_in_at } }
        # it { puts "---->  count: #{@users.count}, firsts.id#{@users.first.id}, user.id#{user.id} ----" } 
        
        # the first user in the list should be the same user just logged in
        it "Should show most recently signed in user at top of list of recently active" do 
            expect(@users.first.id).to eq user.id 
        end 
    end
    
    
  end
end












