# ==============================================================================
# Monkey patch `Kernel#system` to strip --quiet AND force proper bundler/nokogiri setup
# Ensures we remove bad precompiled Nokogiri and recompile with correct flags
# ------------------------------------------------------------------------------
module Kernel
  alias_method :original_system, :system unless method_defined?(:original_system)

  def system(*args)
    if args.any? && args.first.is_a?(String)
      cmd = args.first

      # Intercept `bundle install --quiet` or similar
      if cmd.include?("bundle") && cmd.include?("--quiet")
        cmd = cmd.gsub("--quiet", "")
        puts ""
        puts "##################################################################"
        puts "[kernel_patch] Intercepted system call: #{args.first}"
        puts "[kernel_patch] Modified to: #{cmd}"
        puts "##################################################################"
        puts ""
      end

      # Apply config + environment before ANY bundle call
      if cmd.strip.start_with?("bundle")
        puts ""
        puts "##################################################################"
        puts "[kernel_patch] Setting bundler configs and uninstalling nokogiri (if present)"
        puts "##################################################################"
        puts ""
        original_system("gem uninstall nokogiri -aIx || true")
        original_system("bundle config set force_ruby_platform true")
        original_system("gem install nokogiri -v 1.18.7 --platform=ruby")

        ENV["NOKOGIRI_USE_SYSTEM_LIBRARIES"] = "true"
      end

      return original_system(cmd)
    else
      original_system(*args)
    end
  end
end
