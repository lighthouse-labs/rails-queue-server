class Evaluations::Finish
  include Interactor

  before do
    @evaluation = context.evaluation
  end

  def call
    @evaluation.final_score = calc_final_score(@evaluation)

    # final_score is 1 if failed, otherwise it's the avg
    if passed?(@evaluation)
      @evaluation.transition_to :accepted
    else
      @evaluation.transition_to :rejected
    end
  end

  private

  # if any (except 'version_control') are set to 1, it's a fail
  def passed?(eval)
    eval.result.none? do |criteria, info|
      info['score'] == '1' && criteria != 'version_control'
    end
  end

  def calc_final_score(eval)
    sum = 0
    eval.result.each do |criteria, info|
      sum += info['score'].to_i
    end
    (sum.to_f / eval.result.size.to_f).round(2)
  end

end