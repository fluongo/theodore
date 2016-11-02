info = imaqhwinfo('gige')
basler = videoinput('gige', 1, 'Mono12');
basler_src = getselectedsource(basler);
basler_src.BinningHorizontal = 2;
basler_src.BinningVertical = 2;
preview(basler)
%%
basler_src.AcquisitionFrameRateAbs = 15;
basler_src.ExposureMode = 'Timed';
basler_src.ExposureTimeAbs = 66000;
triggerconfig(basler, 'hardware', 'DeviceSpecific', 'DeviceSpecific')
basler_src.TriggerMode = 'on';
basler.FramesPerTrigger = Inf
%%
start(basler)
%%
for i=1:1000
    pause(1)
    basler.FramesAcquired
end
%%
while basler.FramesAcquired <= basler.FramesPerTrigger-1
    basler.FramesAcquired
end

stop(basler)
%HIMAGE = preview(basler)