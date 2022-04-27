# frozen_string_literal: true

# @summary Return a hash of loaded kernel modules

Facter.add(:kmods) do
  confine kernel: :linux

  kmod = {}

  setcode do
    if File.exist?('/sys/module')
      Dir.foreach('/sys/module') do |directory|
        next if ['.', '..'].include?(directory)

        kmod[directory] = {
          'parameters' => {},
          'used_by' => [],
        }

        if File.directory?("/sys/module/#{directory}/parameters")
          begin
            Dir.foreach("/sys/module/#{directory}/parameters") do |param|
              next if ['.', '..'].include?(param)

              next unless File.readable?("/sys/module/#{directory}/parameters/#{param}")

              kmod[directory]['parameters'][param] = File.read("/sys/module/#{directory}/parameters/#{param}").chomp
            end
          rescue Errno::EACCES => e
            Facter.debug(e)
          rescue StandardError => e
            Facter.warn(e)
          end
        end

        if File.directory?("/sys/module/#{directory}/holders")
          begin
            Dir.foreach("/sys/module/#{directory}/holders") do |used|
              next if ['.', '..'].include?(used)

              kmod[directory]['used_by'] << used
            end
          rescue StandardError => e
            Facter.warn(e)
          end
        end
      end

      kmod
    else
      Facter.debug('/sys/module is not found. skipping.')
    end
  end
end
