require 'spec_helper'

describe EM::FCM::Client do

  USER_AGENT = "em-fcm #{EM::FCM::VERSION}"

  describe "200" do
    before do
      stub_request(:post, EM::FCM::Client::URL).with(
          :body => {
              "registration_ids" => ["ABC"],
              "data" => "hi"
          }.to_json,
          :headers => {
              'Authorization'=>'key=token',
              'Content-Type'=>'application/json',
              'User-Agent'=> USER_AGENT
          }
      ).to_return(
          :status => 200,
          :body => '{"multicast_id":123,"success":0,"failure":1,"canonical_ids":0,"results":[{"error":"InvalidRegistration"}]}'
      )

      fcm = EM::FCM::FCM.new()
      fcm.token = "token"

      EM.run_block do
        fcm.push("ABC", :data => "hi") do |response|
          @response = response
        end
      end
    end

    it "sets status" do
      @response.status.should == 200
    end

    it "parses id from body" do
      @response.multicast_id.should == 123
    end

    it "parses error from body when present" do
      @response.device_results["ABC"].error.should == "InvalidRegistration"
    end

  end

  describe "401" do
    before do
      stub_request(:post, EM::FCM::Client::URL).with(
          :body => {
              "registration_ids" => ["ABC"],
              "data" => "hi"
          }.to_json,
          :headers => {
              'Authorization'=>'key=token',
              'Content-Type'=>'application/json',
              'User-Agent'=> USER_AGENT
          }
      ).to_return(
          :status => 401
      )

      fcm = EM::FCM::FCM.new()
      fcm.token = "token"

      EM.run_block do
        fcm.push("ABC", :data => "hi") do |response|
          @response = response
        end
      end
    end

    it "sets status" do
      @response.status.should == 401
    end

    it "sets InvalidToken error" do
      @response.error.should == "InvalidToken"
    end
  end

  #
  #describe "503 (Retry-After)" do
  #  before do
  #    stub_request(:post, EM::FCM::Client::URL).with(
  #        :query => {
  #            "collapse_key"    => nil,
  #            "data.alert"      => "hi",
  #            "registration_id" => "ABC"
  #        },
  #        :headers => {
  #            'Authorization'=>'GoogleLogin auth=token',
  #            'Content-Length'=>'0',
  #            'User-Agent'=>'em-c2dm 0.0.2'
  #        }
  #    ).to_return(
  #        :status => 503,
  #        :headers => { "Retry-After" => "1234"}
  #    )
  #
  #    c2dm = EM::FCM::C2DM.new()
  #    c2dm.token = "token"
  #
  #    EM.run_block do
  #      c2dm.push("ABC", :alert => "hi") do |response|
  #        @response = response
  #      end
  #    end
  #  end
  #
  #  it "sets status" do
  #    @response.status.should == 503
  #  end
  #
  #  it "sets RetryAfter error" do
  #    @response.error.should == "RetryAfter"
  #  end
  #
  #  it "sets retry_after duration" do
  #    @response.retry_after.should == 1234
  #  end
  #end
  #


  describe "a network error" do
    before do
      stub_request(:post, EM::FCM::Client::URL).with(
          :body => {
              "registration_ids" => ["ABC"],
              "data" => "Error"
          }.to_json,
          :headers => {
              'Authorization'=>'key=token',
              'Content-Type'=>'application/json',
              'User-Agent'=> USER_AGENT
          }
      ).to_timeout

      @log = StringIO.new
      EM::FCM.logger = Logger.new(@log)
    end

    it "logs the error" do
      EM.run_block {
        fcm = EM::FCM::FCM.new()
        fcm.token = "token"
        fcm.push("ABC", :data => "Error")
      }
      @log.rewind
      @log.read.should include("ERROR")
    end

    it "does not run the passed block" do
      block_called = false

      fcm = EM::FCM::FCM.new()
      fcm.token = "token"

      EM.run_block do
        fcm.push("ABC", :data => "Error") do
          block_called = true
        end
      end

      block_called.should be_false
    end
  end

end
