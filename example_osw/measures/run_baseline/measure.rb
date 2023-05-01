class RunBaseline < OpenStudio::Measure::ModelMeasure

  def name
    return 'Run Baseline'
  end

  def description
    return 'Create a corresponding baseline model and run simulation'
  end

  def modeler_description
    return self.description()
  end

  def arguments(model)
    args = OpenStudio::Measure::OSArgumentVector.new
    return args
  end

  def run(model, runner, user_arguments)
    super(model, runner, user_arguments)

    if !runner.validateUserArguments(arguments(model), user_arguments)
      return false
    end

    return true
  end

end
