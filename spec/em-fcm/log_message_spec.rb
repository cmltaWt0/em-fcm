require 'spec_helper'

describe EM::FCM::LogMessage do
  before do
    @notification = EM::FCM::Notification.new("reg_id", :data => "hi")
  end

  it "logs to info on success" do
    response = EM::FCM::Response.new( ["abcd"],
        :id => "fcm_id",
        :status => 200
    )

    EM::FCM.logger.should_receive(:info).with(
        "CODE=200 GUID=#{@notification.uuid} TOKEN=#{@notification.registration_ids} TIME=#{response.duration}"
    )

    EM::FCM::LogMessage.new(@notification, response).log
  end

  it "logs to error on success (with error in payload)" do
    response = EM::FCM::Response.new( ["abcd"],
        :id => "c2dm_id",
        :status => 200,
        :error => "InvalidRegistration"
    )

    EM::FCM.logger.should_receive(:error).with(
        "CODE=200 GUID=#{@notification.uuid} TOKEN=#{@notification.registration_ids} TIME=#{response.duration} ERROR=#{response.error}"
    )

    EM::FCM::LogMessage.new(@notification, response).log
  end

  it "logs to error on failure" do
    response = EM::FCM::Response.new( ["abcd"],
        :id => "c2dm_id",
        :status => 503,
        :error => "RetryAfter"
    )

    EM::FCM.logger.should_receive(:error).with(
        "CODE=503 GUID=#{@notification.uuid} TOKEN=#{@notification.registration_ids} TIME=#{response.duration} ERROR=#{response.error}"
    )

    EM::FCM::LogMessage.new(@notification, response).log
  end
end
