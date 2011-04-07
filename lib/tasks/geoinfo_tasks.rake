namespace :db do  
  namespace :migrate do  
    description = "Migrate the database through scripts in vendor/plugins/geoinfo/lib/db/migrate"  
    description << "and update db/schema.rb by invoking db:schema:dump."  
    description << "Target specific version with VERSION=x. Turn off output with VERBOSE=false."  
    
    desc description 
    task :geoinfo => :environment do  
      ActiveRecord::Migration.verbose = ENV["VERBOSE"] ? ENV["VERBOSE"] == "true"  : true 
      ActiveRecord::Migrator.migrate("vendor/plugins/geoinfo/lib/db/migrate/", ENV["VERSION"] ? ENV["VERSION"].to_i : nil)  
      Rake::Task["db:schema:dump"].invoke if ActiveRecord::Base.schema_format == :ruby  
    end  
  end
  
  namespace :seed do
    desc "Load all data from vendor/plugins/geoinfo/lib/db/*.yml into tables"
    task :geoinfo => :environment do
       g = GeoinfoCity.new
       s = GeoinfoState.new
       db_seed_path = "vendor/plugins/geoinfo/lib/db"
       files = ['states.yml', 'cities.yml'];
       files.map! do |file|
         filepath = File.join(db_seed_path,file)
         YAML::load_file(filepath).each do |obj|
           if(obj)
             obj = obj.class.new(obj.attributes);
             obj.name = obj.name.titlecase if obj.name
             puts "Saving #{obj.name}"
             obj.save!
           end
         end
       end
    end
  end
end 
