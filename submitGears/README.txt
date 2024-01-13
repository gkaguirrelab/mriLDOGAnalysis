To submit these jobs to Flywheel, use the function submitGears that is included in the flywheelMRSupport toolbox. The syntax is:

	submitGears('ldogStructParams.csv')

The order of execution for these should be:

ldogStructParams.csvldogFuncParams.csvldogFixParams.csvThe ldogStruct gear takes a "center of gravity" coordinate. This should be the x,y,z voxel identified in the fsleyes viewer that corresponds to the middle of the corpus callosum on the MPRAGE image. The coordinate value corresponds to the distance (in voxels) from the origin coordinate, which is the left, posterior, inferior voxel.