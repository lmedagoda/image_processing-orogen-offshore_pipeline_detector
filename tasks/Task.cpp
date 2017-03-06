/* Generated from orogen/lib/orogen/templates/tasks/Task.cpp */

#include "Task.hpp"
#include "frame_helper/FrameHelper.h"

using namespace offshore_pipeline_detector;
using namespace frame_helper;
using namespace base::samples::frame;

Task::Task(std::string const& name)
    : TaskBase(name)
{
}

Task::Task(std::string const& name, RTT::ExecutionEngine* engine)
    : TaskBase(name, engine)
{
}

Task::~Task()
{
}


/// The following lines are template definitions for the various state machine
// hooks defined by Orocos::RTT. See Task.hpp for more detailed
// documentation about them.

bool Task::configureHook()
{
    return true;
}

bool Task::startHook()
{
    // init things and check config
    return true;
}

void Task::updateHook()
{

    struct AUVPosition{
    double x;
    double y;
    double z;
    double heading;
    } pos_command; // the position command you want to generate


    // read port

    if (_frame.readNewest(current_frame_)!= RTT::NewData)
        return; //we do not want to process an old image

    // detect pipe and determine control action required

    // create output for control chain
    
    base::LinearAngular6DCommand world_command; // commands need a certain type
    base::LinearAngular6DCommand aligned_position_command; 

    aligned_position_command.x() = pos_command.x;
    aligned_position_command.y() = pos_command.y;

    world_command.z() = pos_command.z;
    world_command.roll() = 0;
    world_command.pitch() = 0;
    world_command.yaw() = pos_command.heading;

    // write to output ports
    _world_command.write(world_command);
    _aligned_position_command.write(aligned_position_command);


    
}

void Task::stopHook()
{
}

void Task::cleanupHook()
{
}

