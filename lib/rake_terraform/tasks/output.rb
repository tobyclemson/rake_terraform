# frozen_string_literal: true

require 'rake_factory'
require 'ruby_terraform'
require 'ostruct'
require 'colored2'

module RakeTerraform
  module Tasks
    class Output < RakeFactory::Task
      default_name :output
      default_prerequisites(RakeFactory::DynamicValue.new do |t|
        [t.ensure_task_name]
      end)
      default_description(RakeFactory::DynamicValue.new do |t|
        "Output #{t.configuration_name} using terraform"
      end)

      parameter :configuration_name, required: true
      parameter :source_directory, required: true
      parameter :work_directory, required: true

      parameter :backend_config

      parameter :state_file

      parameter :debug, default: false
      parameter :input, default: false
      parameter :no_color, default: false
      parameter :no_print_output, default: false

      parameter :ensure_task_name, default: :'terraform:ensure'

      action do |t|
        Colored2.disable! if t.no_color

        module_directory =
          File.join(FileUtils.pwd, t.source_directory)
        configuration_directory =
          File.join(t.work_directory, t.source_directory)

        Kernel.puts("Output of #{t.configuration_name}".cyan)

        FileUtils.rm_rf(configuration_directory)
        FileUtils.mkdir_p(configuration_directory)

        RubyTerraform.init(
          chdir: configuration_directory,
          from_module: module_directory,
          backend_config: t.backend_config,
          no_color: t.no_color,
          input: t.input
        )
        output = RubyTerraform.output(
          chdir: configuration_directory,
          no_color: t.no_color,
          state: t.state_file
        )

        Kernel.puts(output) unless t.no_print_output

        output
      end
    end
  end
end
