require 'spec_helper'

describe EM::FCM::Notification do
  describe "#params" do
    it "includes does not allow empty options" do
      lambda {
        EM::FCM::Notification.new("ABC")
      }.should raise_error

      lambda {
        EM::FCM::Notification.new("ABC", {})
      }.should raise_error
    end

    it "includes registration_id and collapse_key" do
      notification = EM::FCM::Notification.new(["ABC"],
                                                :collapse_key => "foo")


      JSON.parse(notification.body).should == {
          "registration_ids" => ["ABC"],
          "collapse_key"    => "foo"
      }
    end

    it "barfs on string parameters" do

      lambda {
      notification = EM::FCM::Notification.new("ABC",
                                                "collapse_key" => "foo")
      }.should raise_error

    end

    it "rejects unknown params" do

      lambda {
      notification = EM::FCM::Notification.new("ABC",
                                                :collapse_key => "foo",
                                                :alert        => "bar")
      }.should raise_error
    end

    it "checks ttl is a number" do

      notification = EM::FCM::Notification.new(["ABC"],
                                               :time_to_live => 123)


      JSON.parse(notification.body).should == {
          "registration_ids" => ["ABC"],
          "time_to_live"    => 123
      }
    end

    it "rejects string ttl" do

      lambda {
        notification = EM::FCM::Notification.new("ABC",
                                                 :collapse_key => "foo",
                                                 :time_to_live => "123")
      }.should raise_error
    end

  end
end
