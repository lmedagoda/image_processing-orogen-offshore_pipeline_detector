require 'orocos/log'
require 'vizkit'

Orocos.initialize
log = Orocos::Log::Replay.open(ARGV)
port_frame = log.camera_bottom_left.frame

Orocos.run 'offshore_pipeline_detector::Task' => 'detector' do
    #Orocos.log_all_ports
    pipeline_detector = Orocos.get 'detector'
    pipeline_detector.use_channel = 0
    port_frame.connect_to pipeline_detector.frame
    pipeline_detector.configure
    pipeline_detector.start

    Vizkit.display pipeline_detector
    Vizkit.display pipeline_detector.pipeline_overlay
    Vizkit.control log
    Vizkit.exec
end

