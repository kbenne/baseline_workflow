class ReportSavings < OpenStudio::Measure::ReportingMeasure

  def name
    return 'Report Savings'
  end

  def description
    return 'Calculate savings compared to a previously run baseline simulation'
  end

  def modeler_description
    return self.description()
  end

  def arguments()
    args = OpenStudio::Measure::OSArgumentVector.new
    return args
  end

  def run(runner, user_arguments)
    super(runner, user_arguments)

    if !runner.validateUserArguments(arguments(), user_arguments)
      return false
    end

    workflow = runner.workflow

    # Directory for baseline run
    baseline_run_dir = workflow.absoluteRunDir / OpenStudio::Path.new('baseline')
    FileUtils.mkdir_p(baseline_run_dir.to_s)

    # Create baseline osm model
    baseline_osm_path = baseline_run_dir / OpenStudio::Path.new('baseline.osm')
    # This will need to be updated with 179d baseline generator code
    baseline_osm = runner.lastOpenStudioModel.get.clone
    baseline_osm.save(baseline_osm_path, true)

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

    # Get both sql files
    baseline_sql_path = baseline_run_dir / OpenStudio::Path.new('run/eplusout.sql')
    baseline_sql_file = OpenStudio::SqlFile.new(baseline_sql_path)
    sql_file = runner.lastEnergyPlusSqlFile.get

    # Compute savings
    savings = baseline_sql_file.totalSiteEnergy.get - sql_file.totalSiteEnergy.get
    puts savings

    return true
  end

  def energyPlusOutputRequests(runner, user_arguments)
    super(runner, user_arguments)
    return OpenStudio::IdfObjectVector.new
  end

end

ReportSavings.new.registerWithApplication
