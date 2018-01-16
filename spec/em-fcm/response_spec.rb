require 'spec_helper'
require "em-fcm/response"

describe EM::FCM::Response do
  describe "#duration" do
    it "records difference between start and init" do
      now = Time.now
      Time.stub!(:now).and_return(now)
      response = EM::FCM::Response.new(["abc"], {}, now - 5)
      response.duration.should == 5.0
    end
  end

  it "can be instantiated from a hash" do
    response = EM::FCM::Response.new(["abcd"],
        :status       => 200,
        :retry_after  => 10,
        :error        => "InvalidRegistration"
    )

    response.status.should == 200
    response.retry_after.should == 10
    response.error.should == "InvalidRegistration"
  end

  it "should parse a success properly" do
    response = EM::FCM::Response.new(["abcd"],
                                     :status => 200,
                                     :body => '{"multicast_id":123,"success":1,"failure":0,"canonical_ids":1,"results":[{"message_id":"the_id", "error" : "some_error", "registration_id" : "ggg"}]}'
    )

    response.status.should == 200
    response.success.should == 1
    response.failure.should == 0
    response.canonical_ids.should == 1
    response.multicast_id.should == 123
    device_result = response.device_results["abcd"]
    device_result.message_id.should == "the_id"
    device_result.error.should == "some_error"
    device_result.registration_id.should == "ggg"

  end

end
