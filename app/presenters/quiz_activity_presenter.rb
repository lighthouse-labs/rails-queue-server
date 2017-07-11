class QuizActivityPresenter < ActivityPresenter

  def after_instructions
    render 'quiz'
  end

end
