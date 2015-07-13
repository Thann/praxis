require 'spec_helper'

describe 'Nested Hash spec' do
  def app
    Praxis::Application.instance
  end

  let(:session) { double("session", valid?: true)}

  it 'single' do
    payload = {sub_hash: {key:'value'}}.to_json
    the_body = StringIO.new(payload)
    post '/api/clouds/1/instances/nested_hash_test?api_version=1.0', nil,'rack.input' => the_body,'CONTENT_TYPE' => "application/json", 'global_session' => session
    #puts "LR[#{last_response.status}]: #{last_response.body}"
    expect(last_response.status).to eq 200
  end

  it 'multipart' do
    payload = {sub_hash: {key:'value'}}.to_json
    the_body = StringIO.new("--boundary\r\nContent-Disposition: form-data; name=blah\r\n\r\n#{payload}\r\n--boundary--")
    post '/api/clouds/1/instances/mp_nested_hash_test?api_version=1.0', nil,'rack.input' => the_body,'CONTENT_TYPE' => "multipart/form-data; boundary=boundary", 'global_session' => session
    #puts "LR[#{last_response.status}]: #{last_response.body}"
    expect(last_response.status).to eq 200
  end
end
