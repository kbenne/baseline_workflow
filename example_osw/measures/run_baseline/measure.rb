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

    workflow = runner.workflow

    # Directory for baseline run
    baseline_run_dir = File.join(workflow.absoluteRunDir.to_s, 'baseline')
    FileUtils.mkdir_p(baseline_run_dir)

    # Create baseline osm model
    baseline_osm_name = File.join(baseline_run_dir, 'baseline.osm')
    model.clone.save(baseline_osm_name, true)

    # Copy weather file
    weather_file = workflow.findFile(workflow.weatherFile.get).get.to_s

    FileUtils.cp(weather_file, baseline_run_dir)

    return true
  end

end

RunBaseline.new.registerWithApplication
