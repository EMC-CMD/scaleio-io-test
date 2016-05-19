require 'sinatra'
require 'json'
require "json-schema"

def schema
  {
    "type" => "object",
    "required" => ["ScaleIO"],
    "properties" => {
      "ScaleIO" => {
        "type" => "array",
        "items" => {
          "type" => "object",
          "required" => ["volume_mounts"],
          "properties" => {
            "volume_mounts" => {
              "type"=> "array",
              "required" => ["container_path"],
              "items" => {
                "type" => "object",
                "properties" => {
                  "container_path" => {"type" => "string"}
                }
              }
            }
          }
        }
      }
    }
  }
end

def test_file_path
  vcap_services = JSON.parse(ENV["VCAP_SERVICES"])
  JSON::Validator.validate!(schema, vcap_services)
  vcap_services["ScaleIO"][0]["volume_mounts"][0]["container_path"]
end

get '/text' do
  send_file File.join(test_file_path, "test.txt")
end

post '/text' do
  request.body.rewind
  body = request.body.read
  File.write(File.join(test_file_path, "test.txt"), body)
end
