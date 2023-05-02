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
    baseline_run_dir = workflow.absoluteRunDir / OpenStudio::Path.new('baseline')
    FileUtils.mkdir_p(baseline_run_dir.to_s)

    # Create baseline osm model
    baseline_osm_path = baseline_run_dir / OpenStudio::Path.new('baseline.osm')
    model.clone.save(baseline_osm_path, true)

    # Copy weather file
    weather_file_path = workflow.findFile(workflow.weatherFile.get).get
    FileUtils.cp(weather_file_path.to_s, baseline_run_dir.to_s)

    # Create a workflow to run the baseline
    baseline_workflow = OpenStudio::WorkflowJSON.new
    baseline_workflow.setSeedFile(baseline_osm_path)
    baseline_workflow.setWeatherFile(weather_file_path)
    baseline_workflow_path = baseline_run_dir / OpenStudio::Path.new('baseline.osw')
    baseline_workflow.saveAs(baseline_workflow_path)

    # Run the baseline workflow
    cli_path = OpenStudio.getOpenStudioCLI
    cmd = "\"#{cli_path}\" run -w \"#{baseline_workflow_path.to_s}\""
    system(cmd)

    return true
  end

end

RunBaseline.new.registerWithApplication
