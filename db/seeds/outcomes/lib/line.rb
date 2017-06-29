require Rails.root.join("app/models/category")
require Rails.root.join("app/models/skill")
require Rails.root.join("app/models/outcome")

class Category

  def self.upsert!(uuid, name)
    category = Category.find_by(uuid: uuid) || Category.new
    category.uuid = uuid
    category.name = name
    category.save!
  end

end

class Skill

  def self.upsert!(uuid, name, category_uuid)
    skill = Skill.find_by(uuid: uuid) || Skill.new
    skill.uuid = uuid
    skill.name = name
    skill.category = Category.find_by(uuid: category_uuid)
    skill.save!
  end

end

class Outcome

  def self.upsert!(uuid, name, skill_uuid, taxonomy, importance)
    outcome = Outcome.find_by(uuid: uuid) || Outcome.new
    outcome.uuid = uuid
    outcome.text = name
    outcome.taxonomy = taxonomy
    outcome.importance = importance
    outcome.skill = Skill.find_by(uuid: skill_uuid)
    outcome.save!
  end

end

def str_or_nil(v)
  if v.nil?
    return v
  elsif v.instance_of?(String)
    if v.empty?
      return nil
    else
      return v
    end
  end
  nil
end

class Line

  #   :uuid (UUID, nil)
  #   :name ("string", nil)
  #   :type (:category, :skill, nil)
  #   :taxonomy (:knowledge, :skill, :habit, nil)
  #   :importance (:core, :ideal, :extra, nil)

  attr_reader :name, :depth, :uuid, :taxonomy, :importance

  def initialize(row)
    @uuid = row[0]
    @type = if row[1] == "C" then :category
            elsif row[1] == "S" then :skill
            end
    @name = row[3..9].map { |v| str_or_nil(v) }.detect { |v| v }
    @taxonomy = (row[10].to_sym if row[10])
    @importance = (row[11].to_sym if row[11])
    @depth = row[3..9].map.with_index { |x, i| i if x }.detect { |v| v }
  end

  def category?
    true &&
      @uuid &&
      @name &&
      @type == :category &&
      @taxonomy.nil? &&
      @importance.nil?
  end

  def skill?
    true &&
      @uuid &&
      @name &&
      @type == :skill &&
      @taxonomy.nil? &&
      @importance.nil?
  end

  def outcome?
    true &&
      @uuid &&
      @name &&
      @name != "TODO" &&
      @type.nil? &&
      @taxonomy &&
      @importance
  end

  def todo?
    true &&
      outcome? &&
      @name == "TODO"
  end

  def empty?
    true &&
      @uuid.nil? &&
      @name.nil? &&
      @type.nil? &&
      @taxonomy.nil? &&
      @importance.nil?
  end

  def header?
    true &&
      @uuid &&
      @name &&
      @type.nil? &&
      @taxonomy.nil? &&
      @importance.nil?
  end

  def valid?
    category? ||
      skill? ||
      outcome? ||
      todo? ||
      empty? ||
      header?
  end

  def upsert!(parent_id = nil)
    if category?
      Rails.logger.info "\t > category / #{name} (#{uuid})"
      Category.upsert!(uuid, name)
      Rails.logger.info "\t > skill / core / #{uuid}"
      Skill.upsert!(uuid, name, uuid)
    elsif skill?
      Rails.logger.info "\t > skill / #{name} (#{uuid}) / parent: #{parent_id}"
      Skill.upsert!(uuid, name, parent_id)
    elsif outcome?
      Rails.logger.info "\t > outcome / * / parent: #{parent_id}"
      Outcome.upsert!(uuid, name, parent_id, taxonomy, importance)
    end
  end

end
