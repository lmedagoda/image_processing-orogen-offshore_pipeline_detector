require 'vizkit'
require 'orocos/log'
require './pipeline_detector.rb'

include Orocos

if not ARGV[0]
    puts "add a valid logfile folder as parameter"
    exit
end

log = Orocos::Log::Replay.open(ARGV)

@window = Vizkit.load(File.join(File.dirname(__FILE__),"slider.ui"))
@window.show

Orocos.initialize

frames = log.bottom_camera.frame

Orocos.run "offshore_pipeline_detector::Task" => "offshore_pipeline_detector", 'image_preprocessing::HSVSegmentationAndBlur' => 'preprocessing' do

    Orocos.conf.load_dir("#{ENV['AUTOPROJ_CURRENT_ROOT']}/image_processing/orogen/offshore_pipeline_detector/scripts/config/")
    #Orocos.log_all_ports

    offshore_pipeline_detector = TaskContext.get 'offshore_pipeline_detector'
    Orocos.conf.apply(offshore_pipeline_detector, ['default'], :override => true)

    preprocessing = TaskContext.get 'preprocessing'
    Orocos.conf.apply(preprocessing, ['default', 'structure'], :override => true)
    preprocessing.sMin = 0
    preprocessing.sMax = 255

    # connect ports with the task
    frames.connect_to preprocessing
    preprocessing.oframe.connect_to offshore_pipeline_detector.frame

    preprocessing.configure
    preprocessing.start
    offshore_pipeline_detector.configure
    offshore_pipeline_detector.start

    @window.hMax.setValue(preprocessing.hMax)
    @window.hMin.setValue(preprocessing.hMin)
    @window.sMax.setValue(preprocessing.sMax)
    @window.sMin.setValue(preprocessing.sMin)
    @window.vMax.setValue(preprocessing.vMax)
    @window.vMin.setValue(preprocessing.vMin)
    @window.blur.setValue(preprocessing.blur)

    @window.hMax.connect(SIGNAL('sliderMoved(int)')) {|v| preprocessing.hMax= v }
    @window.hMin.connect(SIGNAL('sliderMoved(int)')) {|v| preprocessing.hMin= v }
    @window.sMax.connect(SIGNAL('sliderMoved(int)')) {|v| preprocessing.sMax= v }
    @window.sMin.connect(SIGNAL('sliderMoved(int)')) {|v| preprocessing.sMin= v }
    @window.vMax.connect(SIGNAL('sliderMoved(int)')) {|v| preprocessing.vMax= v }
    @window.vMin.connect(SIGNAL('sliderMoved(int)')) {|v| preprocessing.vMin= v }
    @window.blur.connect(SIGNAL('sliderMoved(int)')) {|v| preprocessing.blur= v }

    Vizkit.control log
    task_inspector = Vizkit.default_loader.TaskInspector
    Vizkit.display offshore_pipeline_detector, :widget => task_inspector
    Vizkit.display preprocessing, :widget => task_inspector
    Vizkit.display offshore_pipeline_detector.debug_frame
    gui = PipelineDetector.new(frames, offshore_pipeline_detector)
    gui.show
    begin
        Vizkit.exec
    rescue Interrupt => e
        offshore_pipeline_detector.stop
        offshore_pipeline_detector.cleanup
    end
end
