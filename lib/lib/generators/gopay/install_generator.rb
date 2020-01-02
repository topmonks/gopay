# frozen_string_literal: true

require 'rails/generators'
require 'rails/generators/base'
require 'rails/generators/active_record'

module Gopay
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include ActiveRecord::Generators::Migration

      desc 'Generates a migration for gopay payments, initializer and routes'

      source_root File.expand_path('templates', __dir__)

      def add_gopay_routes
        route "get 'gopay/payments', to: 'gopay/payments#update', as: :gopay_notification # For notifications from GoPay"
      end

      def copy_gopay_migration
        migration_template 'migration.rb', 'db/migrate/gopay_create_payments.rb', migration_version: migration_version
      end

      def copy_initializer
        template 'gopay.rb', 'config/initializers/gopay.rb'
      end

      private

      def migration_version
        "[#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}]" if Rails.version.start_with?('5')
      end
    end
  end
end
