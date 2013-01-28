require 'rails/generators'
require 'rails/generators/migration'
require 'active_record'
require 'rails/generators/active_record'

module NoNotifierNeeded
  class InstallGenerator < Rails::Generators::Base
    include Rails::Generators::Migration

    source_root File.expand_path("../templates", __FILE__)

    def copy_migration_and_config

      #Config file
      copy_file 'no_notifier_needed_initalizer.rb', 'config/initializers/no_notifier_needed_initalizer.rb'

      #Resque workers
      copy_file "jobs/no_notifier_needed_processor.rb", "app/jobs/no_notifier_needed_processor.rb"

      #create migration
      migration_template 'install.rb', 'db/migrate/install_acts_as_no_notifier_needed.rb'
    end

    def self.next_migration_number(dirname)
      next_migration_number = current_migration_number(dirname) + 1
      if ActiveRecord::Base.timestamped_migrations
        [Time.now.utc.strftime("%Y%m%d%H%M%S"), "%.14d" % next_migration_number].max
      else
        "%.3d" % next_migration_number
      end
    end
  end
end