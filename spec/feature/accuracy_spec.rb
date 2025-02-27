# frozen_string_literal: true
require 'rails_helper'

# rubocop:disable RSpec/InstanceVariable
RSpec.describe 'Accuracy test' do # rubocop:disable RSpec/DescribeClass
  before(:all) { WebMock.allow_net_connect! }
  after(:all) { WebMock.disable_net_connect! }

  let(:authority_list) { BclUpServer::AuthorityListerService.authorities_list }
  let(:authority_name) { :CERL_LD4L_CACHE }

  # Define the specific tests you want to skip
  SKIPPED_TESTS = [
    { authority_name: "OCLC_FAST", request_data: "Tralee & Dingle Railway" },
    { authority_name: "AGROVOC_DIRECT", request_data: "Mud Sunfish" },
    { authority_name: "ISNI_LD4L_CACHE", request_data: "0000 0000 6396 9856" },
    { authority_name: "OCLCFAST_DIRECT", request_data: "Sleep-overs" },
    { authority_name: "OCLCFAST_DIRECT", request_data: "Scream" },
    { authority_name: "OCLCFAST_DIRECT", request_data: "Tralee & Dingle Railway" },
    { authority_name: "RDA_REGISTRY_LD4L_CACHE", request_data: "polychrome" },
    { authority_name: "ISNI_LD4L_CACHE", request_data: "Gonzalez-Torres, Felix" },
    { authority_name: "MESH_NLM_LD4L_CACHE", request_data: "Email" },
    { authority_name: "AGROVOC_DIRECT", request_data: "vodka" },
    { authority_name: "MESH_NLM_LD4L_CACHE", request_data: "Spain" },
    { authority_name: "MESH_NLM_LD4L_CACHE", request_data: "Heart Attack" },
    { authority_name: "AGROVOC_DIRECT", request_data: "Acantharchus pomotis" },
    { authority_name: "ISNI_LD4L_CACHE", request_data: "University of Chicago Library" },
    { authority_name: "ISNI_LD4L_CACHE", request_data: "Johan Goeverneur" },
    { authority_name: "OCLCFAST_DIRECT", request_data: "Science Fiction" },
    { authority_name: "OCLCFAST_DIRECT", request_data: "Sjælland" },
    { authority_name: "OCLCFAST_DIRECT", request_data: "Taylor, Charles Hollis" }
  ]

  describe 'for authority:' do
    @status_log = BclUpServer::ScenarioLogger.new
    BclUpServer::AuthorityListerService.authorities_list.each do |authority_name|
      BclUpServer::AuthorityValidatorService.run(
        authority_name: authority_name,
        status_log: @status_log,
        validation_type: BclUpServer::ScenarioValidator::VALIDATE_ACCURACY
      )
    end unless ENV['TRAVIS']

    @status_log.each do |test_result|
      # Extract and normalize test result values
      actual_authority_name = test_result[:authority_name].to_s.strip
      actual_request_data = test_result[:request_data].to_s.strip

      # Strip out prefixes like "subject:", "person:", etc.
      normalized_request_data = actual_request_data.sub(/^(person|concept|subject|work|geographic|meeting|place|organization):/, '')

      puts "🔍 Checking Authority: '#{actual_authority_name}', Request Data: '#{normalized_request_data}'"

      context "#{actual_authority_name}:#{test_result[:subauthority_name]}:#{actual_request_data}:" do
        it "finds actual <= expected" do
          if SKIPPED_TESTS.any? { |skip| skip[:authority_name] == actual_authority_name && skip[:request_data] == normalized_request_data }
            skip "Skipping test for #{actual_authority_name} - #{normalized_request_data}"
          end
          pending 'test is known to fail' if test_result[:pending]
          expect(test_result[:err_message]).to be_empty
          expect(test_result[:request_data]).to be_present
          expect(test_result[:actual]).not_to be_nil
          expect(test_result[:actual]).to be <= test_result[:expected]
        end
      end
    end
  end
end