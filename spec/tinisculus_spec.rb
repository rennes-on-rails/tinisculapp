require 'spec_helper'

describe 'The TinisculusApp' do
  it 'has tinisculus writen' do
    get '/'
    assert {last_response.body =~ /Tinisculus/}
  end
end