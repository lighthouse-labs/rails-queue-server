class QuizzesController < ApplicationController
  before_action :set_quiz, only: [:show, :destroy, :add_question, :link_question, :remove_question]

  def index
    @quizzes = Quiz.all
  end
  def new
    @quiz = Quiz.create
    redirect_to "/quizzes/#{@quiz.id}/add_question"
  end
  def show
    @submission_stats = @quiz.quiz_submissions.stats
    @question_stats = @quiz.questions.stats(@quiz)

  end
  def destroy
    @quiz.destroy
    redirect_to quizzes_url, notice: "Quiz #{@quiz.id} was successfully destroyed."
  end
  def add_question
    @questions = Question.all
  end
  def link_question
    @quiz.questions << Question.find(params[:question][:id])
    if @quiz.save
      redirect_to "/quizzes/#{@quiz.id}/add_question" if params[:add] == "add"
      redirect_to @quiz, notice: "Questions were successfully added" if params[:add] == "save"
    else
    end
  end

  def remove_question
    question = Question.find(params[:question_id])
    @quiz.questions.delete(question)
    redirect_to @quiz, notice: "Question #{question.id} was successfully removed."
  end

  private
  def set_quiz
    @quiz = params[:id] && params[:id] != "add_question" ? Quiz.find(params[:id]) : Quiz.find(params[:quiz_id])
  end
end
