require Rails.root.join("app/models/category")
require Rails.root.join("app/models/skill")
require Rails.root.join("app/models/outcome")

class Category
  def self.upsert!(uuid, name)
    category = Category.find_by_uuid(uuid) || Category.new
    category.uuid = uuid
    category.name = name
    category.save!
  end
end

class Skill
  def self.upsert!(uuid,name,category_uuid)
    skill = Skill.find_by_uuid(uuid) || Skill.new
    skill.uuid = uuid
    skill.name = name
    skill.category = Category.find_by_uuid(category_uuid)
    skill.save!
  end
end

class Outcome
  def self.upsert!(uuid,name,skill_uuid,taxonomy,importance)
    outcome = Outcome.find_by_uuid(uuid) || Outcome.new
    outcome.uuid = uuid
    outcome.text = name
    outcome.taxonomy = taxonomy
    outcome.importance = importance
    outcome.skill = Skill.find_by_uuid(skill_uuid)
    outcome.save!
  end
end

def str_or_nil(v)
  if v.nil?
    return v
  elsif v.instance_of?(String)
    if v.length == 0
      return nil
    else
      return v
    end
  end
  return nil
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
            else nil end
    @name = row[3..9].map {|v| str_or_nil(v) }.detect {|v| v}
    @taxonomy = if row[10] then row[10].to_sym end
    @importance = if row[11] then row[11].to_sym end
    @depth = row[3..9].map.with_index { |x,i| i if x }.detect {|v| v}
  end

  def category?
    true and
      @uuid and
      @name and
      @type == :category and
      @taxonomy.nil? and
      @importance.nil?
  end

  def skill?
    true and
      @uuid and
      @name and
      @type == :skill and
      @taxonomy.nil? and
      @importance.nil?
  end

  def outcome?
    true and
      @uuid and
      @name and
      @name != "TODO" and
      @type.nil? and
      @taxonomy and
      @importance
  end

  def todo?
    true and
      self.outcome? and
      @name == "TODO"
  end

  def empty?
    true and
      @uuid.nil? and
      @name.nil? and
      @type.nil? and
      @taxonomy.nil? and
      @importance.nil?
  end

  def header?
    true and
      @uuid and
      @name and
      @type.nil? and
      @taxonomy.nil? and
      @importance.nil?
  end

  def valid?
    self.category? or
      self.skill? or
      self.outcome? or
      self.todo? or
      self.empty? or
      self.header?
  end


  def upsert!(parent_id=nil)
    if self.category?
      puts "\t > category / #{self.name} (#{self.uuid})"
      Category.upsert!(self.uuid, self.name)
      puts "\t > skill / core / #{self.uuid}"
      Skill.upsert!(self.uuid, self.name, self.uuid)
    elsif self.skill?
      puts "\t > skill / #{self.name} (#{self.uuid}) / parent: #{parent_id}"
      Skill.upsert!(self.uuid, self.name, parent_id)
    elsif self.outcome?
      puts "\t > outcome / #{"*"} / parent: #{parent_id}"
      Outcome.upsert!(self.uuid, self.name, parent_id, self.taxonomy, self.importance)
    end
  end

end
