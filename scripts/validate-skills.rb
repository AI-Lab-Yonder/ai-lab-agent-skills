#!/usr/bin/env ruby
# frozen_string_literal: true

require "optparse"
require "open3"
require "yaml"

module SkillMetadata
  SEMVER_RE = /\A(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)\z/.freeze
  NAME_RE = /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/.freeze
  LEVELS = %w[beginner advanced].freeze
  CATEGORIES = %w[
    ai
    architecture
    backend
    code-quality
    database
    debugging
    documentation
    frontend
    fullstack
    meta
    security
    testing
  ].freeze
  REQUIRED_FIELDS = %w[name description version level category].freeze

  Result = Struct.new(:errors, :warnings)
  SkillFile = Struct.new(:path, :relative_path, :dir_name, :data)

  class Frontmatter
    attr_reader :body, :data, :errors, :frontmatter, :relative_path

    def initialize(path, root)
      @path = path
      @root = root
      @relative_path = relative(path)
      @errors = []
      @frontmatter = ""
      @body = ""
      @data = {}
    end

    def parse
      text = File.read(@path)
      match = text.match(/\A---\n(.*?)\n---\n?/m)
      unless match
        @errors << "#{relative_path}: missing YAML frontmatter"
        return self
      end

      @frontmatter = match[1]
      @body = text[match[0].length..-1] || ""
      if @frontmatter.each_line.any? { |line| line.match?(/\Adescription:\s*[|>]/) }
        @errors << "#{relative_path}: description must be a simple string, not a block scalar"
      end

      begin
        @data = YAML.safe_load(@frontmatter) || {}
      rescue Psych::Exception => e
        @errors << "#{relative_path}: invalid YAML frontmatter: #{e.message}"
        @data = {}
      end

      self
    end

    private

    def relative(path)
      path.sub(%r{\A#{Regexp.escape(@root)}/?}, "")
    end
  end

  class VersionPolicy
    class << self
      def evaluate(path:, previous_version:, current_version:, changed_files:, diff_stats:)
        errors = []
        warnings = []

        unless semver?(current_version)
          errors << "#{path}: version `#{current_version}` is not strict semver MAJOR.MINOR.PATCH"
          return [errors, warnings]
        end

        if previous_version.nil?
          unless current_version == "1.0.0"
            errors << "#{path}: new skill must start at version 1.0.0, found #{current_version}"
          end
          return [errors, warnings]
        end

        unless semver?(previous_version)
          errors << "#{path}: base version `#{previous_version}` is not strict semver MAJOR.MINOR.PATCH"
          return [errors, warnings]
        end

        previous = parse(previous_version)
        current = parse(current_version)

        if current == previous
          errors << "#{path}: changed skill did not increase version"
          return [errors, warnings]
        end

        if compare(current, previous).negative?
          errors << "#{path}: version decreased from #{previous_version} to #{current_version}"
          return [errors, warnings]
        end

        bump = classify_bump(previous, current)
        case bump
        when :patch, :minor, :major
          add_guidance_warnings(path, bump, changed_files, diff_stats, warnings)
        when :patch_skip
          errors << "#{path}: patch version skipped from #{previous_version} to #{current_version}"
        when :minor_skip
          errors << "#{path}: minor version skipped from #{previous_version} to #{current_version}"
        when :major_jump
          errors << "#{path}: major version jumped from #{previous_version} to #{current_version}"
        else
          errors << "#{path}: version changed from #{previous_version} to #{current_version} but is not a valid single-step semver bump"
        end

        [errors, warnings]
      end

      private

      def semver?(value)
        value.is_a?(String) && value.match?(SEMVER_RE)
      end

      def parse(value)
        value.split(".").map(&:to_i)
      end

      def compare(left, right)
        left <=> right
      end

      def classify_bump(previous, current)
        prev_major, prev_minor, prev_patch = previous
        major, minor, patch = current

        return :major if major == prev_major + 1 && minor.zero? && patch.zero?
        return :major_jump if major > prev_major + 1
        return :other if major > prev_major

        return :minor if major == prev_major && minor == prev_minor + 1 && patch.zero?
        return :minor_skip if major == prev_major && minor > prev_minor + 1
        return :other if minor > prev_minor

        return :patch if major == prev_major && minor == prev_minor && patch == prev_patch + 1
        return :patch_skip if major == prev_major && minor == prev_minor && patch > prev_patch + 1

        :other
      end

      def add_guidance_warnings(path, bump, changed_files, diff_stats, warnings)
        if bump == :major && diff_stats[:files] <= 1 && diff_stats[:additions] + diff_stats[:deletions] <= 5
          warnings << "#{path}: major version bump has a very small diff; confirm this is a breaking skill change"
        end

        if bump == :patch && (changed_files.length >= 3 || diff_stats[:additions] + diff_stats[:deletions] >= 75)
          warnings << "#{path}: patch version bump has a broad diff; consider whether this should be a minor or major bump"
        end

        if diff_stats[:version_only]
          warnings << "#{path}: version changed without other skill content changes"
        end
      end
    end
  end

  class Validator
    attr_reader :errors, :warnings

    def initialize(root:, base_ref: nil, out: $stdout, err: $stderr)
      @root = File.expand_path(root)
      @base_ref = base_ref
      @out = out
      @err = err
      @errors = []
      @warnings = []
      @skill_files = []
    end

    def run
      validate_current_tree
      validate_changed_versions if @base_ref && @errors.empty?
      Result.new(@errors, @warnings)
    end

    private

    def validate_current_tree
      skills_dir = File.join(@root, "skills")
      unless Dir.exist?(skills_dir)
        @errors << "skills/: directory is missing"
        return
      end

      names = {}
      skill_dirs = Dir.children(skills_dir).sort.select { |entry| File.directory?(File.join(skills_dir, entry)) }
      skill_dirs.each do |dir_name|
        skill_path = File.join(skills_dir, dir_name, "SKILL.md")
        unless File.exist?(skill_path)
          @errors << "skills/#{dir_name}/SKILL.md: missing SKILL.md"
          next
        end

        parsed = Frontmatter.new(skill_path, @root).parse
        @errors.concat(parsed.errors)
        data = parsed.data
        rel = parsed.relative_path

        validate_required_fields(rel, data)
        validate_name(rel, dir_name, data, names)
        validate_description(rel, data)
        validate_version_shape(rel, data)
        validate_level(rel, data)
        validate_category(rel, data)
        validate_body(rel, parsed.body)

        @skill_files << SkillFile.new(skill_path, rel, dir_name, data)
      end
    end

    def validate_required_fields(rel, data)
      REQUIRED_FIELDS.each do |field|
        value = data[field]
        if value.nil? || (value.respond_to?(:empty?) && value.empty?)
          @errors << "#{rel}: missing required field `#{field}`"
        end
      end
    end

    def validate_name(rel, dir_name, data, names)
      name = data["name"]
      return unless name.is_a?(String)

      @errors << "#{rel}: name `#{name}` must be kebab-case" unless name.match?(NAME_RE)
      @errors << "#{rel}: name `#{name}` must match directory `#{dir_name}`" unless name == dir_name

      if names.key?(name)
        @errors << "skill name `#{name}` is duplicated in #{names[name]} and #{rel}"
      else
        names[name] = rel
      end
    end

    def validate_description(rel, data)
      description = data["description"]
      return if description.nil?

      unless description.is_a?(String) && !description.strip.empty?
        @errors << "#{rel}: description must be a non-empty string"
      end
    end

    def validate_version_shape(rel, data)
      version = data["version"]
      return if version.nil?

      unless version.is_a?(String) && version.match?(SEMVER_RE)
        @errors << "#{rel}: version `#{version}` is not strict semver MAJOR.MINOR.PATCH"
      end
    end

    def validate_level(rel, data)
      level = data["level"]
      return if level.nil?

      @errors << "#{rel}: level `#{level}` is not allowed" unless LEVELS.include?(level)
    end

    def validate_category(rel, data)
      category = data["category"]
      return if category.nil?

      @errors << "#{rel}: category `#{category}` is not allowed" unless CATEGORIES.include?(category)
    end

    def validate_body(rel, body)
      if body.strip.empty?
        @errors << "#{rel}: Markdown body is empty"
        return
      end

      in_fence = false
      heading_count = 0
      body.each_line do |line|
        in_fence = !in_fence if line.match?(/\A(```|~~~)/)
        heading_count += 1 if !in_fence && line.match?(/\A#\s+\S/)
      end
      unless heading_count == 1
        @errors << "#{rel}: expected exactly one top-level `#` heading, found #{heading_count}"
      end
    end

    def validate_changed_versions
      changed = changed_skill_files
      changed.group_by { |path| path.split("/")[1] }.each do |dir_name, files|
        next unless dir_name

        skill = @skill_files.find { |item| item.dir_name == dir_name }
        current_version = skill && skill.data["version"]
        previous_text = git_show("#{@base_ref}:skills/#{dir_name}/SKILL.md")
        previous_version = extract_version(previous_text)
        path = "skills/#{dir_name}/SKILL.md"
        stats = diff_stats_for(files)

        errors, warnings = VersionPolicy.evaluate(
          path: path,
          previous_version: previous_version,
          current_version: current_version,
          changed_files: files,
          diff_stats: stats
        )
        @errors.concat(errors)
        @warnings.concat(warnings)
      end
    end

    def changed_skill_files
      output, status = run_git("diff", "--name-only", "#{@base_ref}...HEAD", "--", "skills")
      unless status.success?
        @errors << "unable to compare changed skills against #{@base_ref}: #{output.strip}"
        return []
      end

      output.lines.map(&:strip).reject(&:empty?)
    end

    def diff_stats_for(files)
      output, status = run_git("diff", "--numstat", "#{@base_ref}...HEAD", "--", *files)
      additions = 0
      deletions = 0
      if status.success?
        output.lines.each do |line|
          added, removed, = line.split(/\s+/, 3)
          additions += added.to_i if added && added != "-"
          deletions += removed.to_i if removed && removed != "-"
        end
      end

      {
        files: files.length,
        additions: additions,
        deletions: deletions,
        version_only: version_only_change?(files)
      }
    end

    def version_only_change?(files)
      return false unless files.length == 1 && files.first.end_with?("/SKILL.md")

      output, status = run_git("diff", "--unified=0", "#{@base_ref}...HEAD", "--", files.first)
      return false unless status.success?

      changed_lines = output.lines.select { |line| line.match?(/\A[+-][^+-]/) }
      changed_lines.any? && changed_lines.all? { |line| line.match?(/\A[+-]version:\s/) }
    end

    def extract_version(text)
      return nil unless text

      match = text.match(/\A---\n(.*?)\n---\n?/m)
      return nil unless match

      data = YAML.safe_load(match[1]) || {}
      data["version"]
    rescue Psych::Exception
      nil
    end

    def git_show(spec)
      output, status = run_git("show", spec)
      status.success? ? output : nil
    end

    def run_git(*args)
      Open3.capture2e("git", "-C", @root, *args)
    end
  end

  class CLI
    def self.run(argv, out: $stdout, err: $stderr)
      options = { root: Dir.pwd }
      parser = OptionParser.new do |opts|
        opts.banner = "Usage: ruby scripts/validate-skills.rb [--base REF] [--root PATH]"
        opts.on("--base REF", "Compare changed skill versions against REF") { |value| options[:base_ref] = value }
        opts.on("--root PATH", "Repository root") { |value| options[:root] = value }
      end
      parser.parse!(argv)

      result = Validator.new(root: options[:root], base_ref: options[:base_ref], out: out, err: err).run
      result.warnings.each { |warning| out.puts "::warning::#{warning}" }
      result.errors.each { |error| err.puts "::error::#{error}" }

      if result.errors.empty?
        out.puts "Validated skill metadata successfully"
        0
      else
        err.puts "Skill metadata validation failed with #{result.errors.length} error(s)"
        1
      end
    end
  end
end

exit SkillMetadata::CLI.run(ARGV) if __FILE__ == $PROGRAM_NAME
