class TestActivity < Activity

  belongs_to :programming_test

  def display_duration?
    false
  end

end
