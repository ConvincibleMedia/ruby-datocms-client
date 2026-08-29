# frozen_string_literal: true

require "io/console"
require "fileutils"
require "tmpdir"

SPECS = %w[
  spec/dato/local/loader_spec.rb
  spec/dato/local/items_repo_integration_spec.rb
  spec/dato/dump/runner_spec.rb
].freeze

CASSETTES = %w[
  spec/fixtures/vcr_cassettes/Dato_Local_Loader/fetches_an_entire_site.yml
  spec/fixtures/vcr_cassettes/Dato_Local_ItemsRepo/_to_hash/dump_everything_you_might_need.yml
  spec/fixtures/vcr_cassettes/Dato_Local_ItemsRepo/multi_language/returns_localized_data_correctly.yml
  spec/fixtures/vcr_cassettes/Dato_Dump_Runner/_run/generates_directories_and_files.yml
].freeze

CREDENTIAL_NAMES = %w[
  DATOCMS_TEST_ACCOUNT_EMAIL
  DATOCMS_TEST_ACCOUNT_PASSWORD
].freeze

DOTENV_PATH = File.expand_path("../.env", __dir__)

def dotenv_credentials(path)
  return {} unless File.file?(path)

  File.foreach(path).each_with_object({}) do |line, credentials|
    line = line.chomp
    match = line.match(/\A\s*(?:export\s+)?([A-Za-z_][A-Za-z0-9_]*)=(.*)\z/)
    next unless match

    name = match[1]
    next unless CREDENTIAL_NAMES.include?(name)

    value = match[2].strip
    quote = value[0]
    if ["\"", "'"].include?(quote) && value[-1] == quote
      value = value[1...-1]
    end

    credentials[name] = value
  end
end

def prompt(label)
  print label
  value = $stdin.gets
  abort "No value provided" unless value

  value.chomp
end

def prompt_for_password
  print "DatoCMS test account password: "
  value = $stdin.noecho(&:gets)
  puts
  abort "No password provided" unless value

  value.chomp
end

dotenv = dotenv_credentials(DOTENV_PATH)

email = ENV["DATOCMS_TEST_ACCOUNT_EMAIL"] ||
        dotenv["DATOCMS_TEST_ACCOUNT_EMAIL"] ||
        prompt("DatoCMS test account email: ")
password = ENV["DATOCMS_TEST_ACCOUNT_PASSWORD"] ||
           dotenv["DATOCMS_TEST_ACCOUNT_PASSWORD"] ||
           prompt_for_password

abort "Email cannot be empty" if email.empty?
abort "Password cannot be empty" if password.empty?

puts
puts "This will overwrite four VCR cassettes using the live DatoCMS API."
puts "Each spec creates a disposable project and deletes it during teardown."
confirmation = prompt("Continue? [y/N]: ")
exit 1 unless confirmation.match?(/\Ay(?:es)?\z/i)

environment = {
  "DATOCMS_LIVE_TESTS" => "1",
  "DATOCMS_TEST_ACCOUNT_EMAIL" => email,
  "DATOCMS_TEST_ACCOUNT_PASSWORD" => password,
}

success = false
status = 1

begin
  Dir.mktmpdir("datocms-cassette-backup-") do |backup_dir|
    backups = {}
    CASSETTES.each_with_index do |cassette, index|
      next unless File.exist?(cassette)

      backup = File.join(backup_dir, "#{index}.yml")
      FileUtils.cp(cassette, backup)
      backups[cassette] = backup
    end

    begin
      CASSETTES.each { |cassette| FileUtils.rm_f(cassette) }

      success = system(
        environment,
        "bundle",
        "exec",
        "rspec",
        "--fail-fast",
        *SPECS,
      )
      status = $?.exitstatus

      if success
        missing = CASSETTES.reject { |cassette| File.exist?(cassette) }
        leaked = CASSETTES.select do |cassette|
          next false unless File.exist?(cassette)

          contents = File.binread(cassette)
          unredacted_project_token = contents.match?(
            /"(?:access_token|readonly_token|readwrite_token)":"(?!<DATOCMS_)[^"]+"/,
          )

          contents.include?(email) ||
            contents.include?(password) ||
            unredacted_project_token
        end

        if missing.any? || leaked.any?
          warn "Cassette verification failed; restoring the previous cassettes."
          success = false
          status = 1
        end
      end
    ensure
      unless success
        CASSETTES.each { |cassette| FileUtils.rm_f(cassette) }
        backups.each do |cassette, backup|
          FileUtils.cp(backup, cassette)
        end
      end
    end
  end
ensure
  password.replace("\0" * password.bytesize)
end

exit status
