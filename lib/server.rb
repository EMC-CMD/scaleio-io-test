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

def test_folder_path
  vcap_services = JSON.parse(ENV["VCAP_SERVICES"])
  JSON::Validator.validate!(schema, vcap_services)
  vcap_services["ScaleIO"][0]["volume_mounts"][0]["container_path"]
end

get "/" do
  @filepath = test_folder_path
  if File.exist?(File.join(test_folder_path, "test.txt"))
    @filecontent = File.read(File.join(test_folder_path, "test.txt"))
  else
    @filecontent = ""
  end
  @instance = ENV["CF_INSTANCE_INDEX"]

  erb :index
end

post "/" do
  File.write(File.join(test_folder_path, "test.txt"), params[:filecontent])
  @filepath = test_folder_path
  @instance = ENV["CF_INSTANCE_INDEX"]
  @filecontent = File.read(File.join(test_folder_path, "test.txt"))
  erb :index
end
