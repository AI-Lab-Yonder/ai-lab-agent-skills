require "fileutils"
require "open3"
require "tmpdir"
require "minitest/autorun"

require_relative "validate-skills"

class SkillMetadataValidatorTest < Minitest::Test
  def setup
    @root = Dir.mktmpdir
    FileUtils.mkdir_p(File.join(@root, "skills"))
  end

  def teardown
    FileUtils.remove_entry(@root)
  end

  def test_accepts_valid_skill_metadata
    write_skill("api-builder")

    result = validate

    assert_empty result.errors
  end

  def test_requires_level_and_restricts_category
    write_skill("api-builder", metadata: { "level" => nil, "category" => "whatever" })

    result = validate

    assert_includes result.errors, "skills/api-builder/SKILL.md: missing required field `level`"
    assert_includes result.errors, "skills/api-builder/SKILL.md: category `whatever` is not allowed"
  end

  def test_rejects_duplicate_names_and_directory_mismatch
    write_skill("api-builder", metadata: { "name" => "shared-name" })
    write_skill("frontend-dev", metadata: { "name" => "shared-name" })

    result = validate

    assert_includes result.errors, "skills/api-builder/SKILL.md: name `shared-name` must match directory `api-builder`"
    assert_includes result.errors, "skills/frontend-dev/SKILL.md: name `shared-name` must match directory `frontend-dev`"
    assert_includes result.errors, "skill name `shared-name` is duplicated in skills/api-builder/SKILL.md and skills/frontend-dev/SKILL.md"
  end

  def test_rejects_block_scalar_descriptions
    write_skill("api-builder", description_line: "description: |\n  Build APIs when needed.")

    result = validate

    assert_includes result.errors, "skills/api-builder/SKILL.md: description must be a simple string, not a block scalar"
  end

  def test_requires_exactly_one_top_level_heading
    write_skill("api-builder", body: "# API Builder\n\n# Extra Heading\n")

    result = validate

    assert_includes result.errors, "skills/api-builder/SKILL.md: expected exactly one top-level `#` heading, found 2"
  end

  def test_ignores_hash_comments_inside_fenced_code_when_counting_headings
    write_skill("api-builder", body: "# API Builder\n\n```bash\n# Run the thing\nruby scripts/validate-skills.rb\n```\n")

    result = validate

    assert_empty result.errors
  end

  def test_version_policy_allows_single_patch_minor_and_major_steps
    assert_version_valid "1.0.0", "1.0.1"
    assert_version_valid "1.0.0", "1.1.0"
    assert_version_valid "1.0.0", "2.0.0"
  end

  def test_version_policy_rejects_objective_errors
    assert_version_error "1.0.0", "1.0.0", "changed skill did not increase version"
    assert_version_error "1.0.1", "1.0.0", "version decreased from 1.0.1 to 1.0.0"
    assert_version_error "1.0.0", "1.0.2", "patch version skipped from 1.0.0 to 1.0.2"
    assert_version_error "1.0.0", "1.2.0", "minor version skipped from 1.0.0 to 1.2.0"
    assert_version_error "1.0.0", "3.0.0", "major version jumped from 1.0.0 to 3.0.0"
  end

  def test_new_skills_must_start_at_v1
    errors, warnings = SkillMetadata::VersionPolicy.evaluate(
      path: "skills/new-skill/SKILL.md",
      previous_version: nil,
      current_version: "1.1.0",
      changed_files: ["skills/new-skill/SKILL.md"],
      diff_stats: { files: 1, additions: 10, deletions: 0, version_only: false }
    )

    assert_includes errors, "skills/new-skill/SKILL.md: new skill must start at version 1.0.0, found 1.1.0"
    assert_empty warnings
  end

  def test_version_policy_emits_guidance_warnings
    major_errors, major_warnings = SkillMetadata::VersionPolicy.evaluate(
      path: "skills/api-builder/SKILL.md",
      previous_version: "1.0.0",
      current_version: "2.0.0",
      changed_files: ["skills/api-builder/SKILL.md"],
      diff_stats: { files: 1, additions: 1, deletions: 0, version_only: false }
    )
    patch_errors, patch_warnings = SkillMetadata::VersionPolicy.evaluate(
      path: "skills/api-builder/SKILL.md",
      previous_version: "1.0.0",
      current_version: "1.0.1",
      changed_files: ["skills/api-builder/SKILL.md", "skills/api-builder/references/api.md", "skills/api-builder/templates/request.tmpl"],
      diff_stats: { files: 3, additions: 80, deletions: 20, version_only: false }
    )

    assert_empty major_errors
    assert_includes major_warnings, "skills/api-builder/SKILL.md: major version bump has a very small diff; confirm this is a breaking skill change"
    assert_empty patch_errors
    assert_includes patch_warnings, "skills/api-builder/SKILL.md: patch version bump has a broad diff; consider whether this should be a minor or major bump"
  end

  def test_validator_compares_changed_skill_against_git_base
    write_skill("api-builder")
    git("init")
    git("config", "user.email", "ci@example.test")
    git("config", "user.name", "CI Test")
    git("add", ".")
    git("commit", "-m", "base")
    base = git("rev-parse", "HEAD").strip

    write_skill("api-builder", body: "# API Builder\n\nChanged content.\n")
    git("add", ".")
    git("commit", "-m", "change without version bump")
    unchanged = SkillMetadata::Validator.new(root: @root, base_ref: base).run
    assert_includes unchanged.errors, "skills/api-builder/SKILL.md: changed skill did not increase version"

    write_skill("api-builder", metadata: { "version" => "1.0.1" }, body: "# API Builder\n\nChanged content.\n")
    git("add", ".")
    git("commit", "-m", "bump version")
    bumped = SkillMetadata::Validator.new(root: @root, base_ref: base).run
    assert_empty bumped.errors
  end

  private

  def validate
    SkillMetadata::Validator.new(root: @root).run
  end

  def write_skill(name, metadata: {}, description_line: nil, body: nil)
    dir = File.join(@root, "skills", name)
    FileUtils.mkdir_p(dir)
    data = {
      "name" => name,
      "description" => "Build APIs when needed.",
      "version" => "1.0.0",
      "level" => "beginner",
      "category" => "backend"
    }.merge(metadata)
    frontmatter_lines = ["---"]
    frontmatter_lines << "name: #{data["name"]}" unless data["name"].nil?
    if description_line
      frontmatter_lines << description_line
    elsif !data["description"].nil?
      frontmatter_lines << "description: #{data["description"].inspect}"
    end
    frontmatter_lines << "version: #{data["version"]}" unless data["version"].nil?
    frontmatter_lines << "level: #{data["level"]}" unless data["level"].nil?
    frontmatter_lines << "category: #{data["category"]}" unless data["category"].nil?
    frontmatter_lines << "---"
    File.write(File.join(dir, "SKILL.md"), "#{frontmatter_lines.join("\n")}\n\n#{body || "# #{titleize(name)}\n\nContent.\n"}")
  end

  def assert_version_valid(previous, current)
    errors, warnings = SkillMetadata::VersionPolicy.evaluate(
      path: "skills/api-builder/SKILL.md",
      previous_version: previous,
      current_version: current,
      changed_files: ["skills/api-builder/SKILL.md"],
      diff_stats: { files: 1, additions: 12, deletions: 3, version_only: false }
    )

    assert_empty errors
    assert_empty warnings
  end

  def assert_version_error(previous, current, message)
    errors, = SkillMetadata::VersionPolicy.evaluate(
      path: "skills/api-builder/SKILL.md",
      previous_version: previous,
      current_version: current,
      changed_files: ["skills/api-builder/SKILL.md"],
      diff_stats: { files: 1, additions: 12, deletions: 3, version_only: false }
    )

    assert_includes errors, "skills/api-builder/SKILL.md: #{message}"
  end

  def titleize(value)
    value.split("-").map(&:capitalize).join(" ")
  end

  def git(*args)
    output, status = Open3.capture2e("git", "-C", @root, *args)
    raise "git #{args.join(" ")} failed: #{output}" unless status.success?

    output
  end
end
