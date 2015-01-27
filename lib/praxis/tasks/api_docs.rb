namespace :praxis do
  desc "Generate API docs (JSON definitions) for a Praxis App"
  task :api_docs => [:environment] do |t, args|
    require 'fileutils'

    Praxis::Blueprint.caching_enabled = false
    generator = Praxis::RestfulDocGenerator.new(Dir.pwd)
  end

  desc "API Documentation Browser"
  task :doc_browser, [:port] => :api_docs do |t, args|
    args.with_defaults port: 4567

    public_folder =  File.expand_path("../../../", __FILE__) + "/api_browser/app"
    app = Rack::Builder.new do
      map "/docs" do # application JSON docs
        use Rack::Static, urls: [""], root: File.join(Dir.pwd, Praxis::RestfulDocGenerator::API_DOCS_DIRNAME)
      end
      map "/" do # Assets mapping
        use Rack::Static, urls: [""], root: public_folder, index: "index.html"
      end

      run lambda { |env| [404, {'Content-Type' => 'text/plain'}, ['Not Found']] }
    end

    
    Rack::Server.start app: app, Port: args[:port]
  end
  
  desc "Validate API docs against Swagger 2.0 schema"
  task :validate do
    require 'json-schema'
    schema_path = 'praxis-resource-schema.json'
#    doc_path = 'swagger_docs/1.0.0/swagger.json'
    doc_path = 'test.json'
    
    schema_reader = JSON::Schema::Reader.new(:accept_uri => false, :accept_file => true)

    errors = JSON::Validator.fully_validate(schema_path, doc_path, :schema_reader => schema_reader, errors_as_objects: true)
    puts "Error count: #{errors.size}"
    errors.each do |error|
      puts error
    end
  end
    
end
