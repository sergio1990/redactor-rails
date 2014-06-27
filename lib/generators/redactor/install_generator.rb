require 'rails/generators'
require 'rails/generators/migration'
module Redactor
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      include ::Rails::Generators::Migration
      desc "Generates migration for Tag and Tagging models"

      class_option :orm, type: :string, default: "active_record", desc: "Backend processor for upload support"

      class_option :backend, type: :string, default: 'carrierwave', desc: "carrierwave(default)"

      def self.source_root
        @source_root ||= File.expand_path(File.join(File.dirname(__FILE__), 'templates'))
      end

      def self.next_migration_number(dirname)
        Time.now.strftime("%Y%m%d%H%M%S")
      end

      def mount_engine
        route "mount RedactorRails::Engine => '/redactor_rails'"
      end

      def create_models
        [:asset, :picture, :attachment].each do |filename|
          template "#{generator_dir}/redactor/#{filename}.rb", File.join('app/models', redactor_dir, "#{filename}.rb")
        end

        if backend == "carrierwave"
          [:picture, :attachment].each do |filename|
            template "#{uploaders_dir}/uploaders/redactor_rails_#{filename}_uploader.rb", File.join("app/uploaders", "redactor_rails_#{filename}_uploader.rb")
          end
        end
      end

      def create_redactor_rails_migration
        if orm.to_s == "active_record"
          migration_template "#{generator_dir}/migration.rb", File.join('db/migrate', "create_redactor_assets.rb")
        end
      end

      def create_initializer
        template "#{orm_dir}/redactor_rails_paperclip.rb", File.join('config/initializers', "redactor_rails_paperclip.rb")
      end

      protected

      def redactor_dir
        'redactor_rails'
      end

      def generator_dir
        @generator_dir ||= [orm, backend].join('/')
      end

      def orm_dir
        @orm_dir ||= [orm].join('/')
      end

      def uploaders_dir
        @uploaders_dir ||= ['base', 'carrierwave'].join('/')
      end

      def orm
        options[:orm] || "active_record"
      end

      def backend
        options[:backend] || "carrierwave"
      end

    end
  end
end
