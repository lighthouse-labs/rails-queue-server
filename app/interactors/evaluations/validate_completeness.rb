# These validations are better in this layer instead of model
# This is b/c in some cases we don't want to trigger them
class Evaluations::ValidateCompleteness

  include Interactor

  before do
    @evaluation = context.evaluation
    @evaluation_form = context.evaluation_form
  end

  def call
    @evaluation.evaluation_rubric.each do |criteria, details|
      name = details['name']
      info = @evaluation_form['result'][criteria] || {}

      if !%w[1 2 3 4].include? info['score'].to_s
        @evaluation.errors.add :base, "Score for #{name} is required"
      elsif (info['score'] == '1' || info['score'] == '2') && info['feedback'].blank?
        @evaluation.errors.add :base, "Feedback for #{name} is required (since it scored less than Acceptable)"
      end
    end

    context.fail! if @evaluation.errors.any?
  end

end
